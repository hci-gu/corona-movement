const moment = require('moment')
const { getBusinessDaysBetween } = require('../../utils/date')
const userCollection = require('./users')
const COLLECTION = 'steps'
let collection

const save = async (dataPoints) => {
  await collection.insertMany(
    dataPoints.map((point) => ({
      ...point,
      date: new Date(point.date),
      date_from: new Date(point.date_from),
      date_to: new Date(point.date_to),
    }))
  )
}

const getQuery = ({ id, from, to, weekDays }) => {
  const query = {
    date: {
      $gte: new Date(from),
      $lt: new Date(to),
    },
    duration: { $lte: 360000000 },
  }
  if (weekDays !== undefined) {
    query['day'] = { $in: weekDays ? [1, 2, 3, 4, 5] : [0, 6] }
  }
  if (id !== 'all') {
    query['id'] = id
  }

  return query
}

const getAverageHour = async ({ id, from, to, weekDays }) => {
  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)
  const weekendDiff = daysDiff - weekdayDiff

  const result = (
    await collection
      .query({
        duration: { $lte: 360000000 },
      })
      .aggregate([
        {
          $match: getQuery({ id, from, to, weekDays }),
        },
        {
          $group: {
            _id: {
              $hour: { date: '$date', timezone: 'Europe/Stockholm' },
            },
            value: { $sum: '$value' },
          },
        },
        {
          $sort: { _id: 1 },
        },
      ])
      .toArray()
  ).map((o) => {
    return {
      ...o,
      value: o.value / (weekDays ? weekdayDiff : weekendDiff),
      key: o._id,
    }
  })

  return {
    from,
    to,
    result: Array.from({ length: 24 }).map((_, i) => {
      const match = result.find((o) => o.key === i)
      if (match) {
        return match
      }
      return {
        key: i,
        value: 0,
      }
    }),
  }
}

const getHoursForEveryone = async ({ from, to }) => {
  const users = await userCollection.getAllExcept()
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  const usersHours = (
    await Promise.all(
      users.map(async (user) =>
        getHours({ id: user._id.toString(), from, to }).then(
          ({ result }) => result
        )
      )
    )
  ).flat()

  const result = dates
    .map((date) =>
      Array.from({
        length: 24,
      }).map((_, hour) => {
        const pad = (hour) => (hour < 10 ? `0${hour}` : `${hour}`)
        const key = `${date} ${pad(hour)}`
        const data = usersHours.filter((datum) => datum.key === key)
        return {
          key: key,
          value: data.reduce((sum, d) => sum + d.value, 0) / (data.length || 1),
        }
      })
    )
    .flat()

  return {
    result,
    from,
    to,
  }
}

const getHours = async ({ id, from, to }) => {
  if (id === 'all') {
    return getHoursForEveryone({ from, to })
  }

  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)

  const result = (
    await collection
      .aggregate([
        {
          $match: getQuery({ id, from, to }),
        },
        {
          $group: {
            _id: {
              $dateToString: {
                format: '%Y-%m-%d %H',
                date: '$date',
                timezone: 'Europe/Stockholm',
              },
            },
            value: { $sum: '$value' },
          },
        },
        {
          $sort: { _id: 1 },
        },
      ])
      .toArray()
  ).map((o) => {
    return {
      ...o,
      key: o._id,
    }
  })

  return {
    from,
    to,
    result: result,
  }
}

const getDays = async ({ id, from, to }) => {
  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)

  const result = (
    await collection
      .aggregate([
        {
          $match: getQuery({ id, from, to }),
        },
        {
          $group: {
            _id: {
              $dateToString: {
                format: '%Y-%m-%d',
                date: '$date',
                timezone: 'Europe/Stockholm',
              },
            },
            value: { $sum: '$value' },
          },
        },
        {
          $sort: { _id: 1 },
        },
      ])
      .toArray()
  ).map((o) => {
    return {
      ...o,
      key: o._id,
    }
  })

  return {
    from,
    to,
    result: result,
  }
}

const getAverageStepsForUser = async ({ id, from, to }) => {
  const result = await collection
    .aggregate([
      {
        $match: getQuery({ id, from, to }),
      },
      {
        $group: {
          _id: 'total',
          value: { $sum: '$value' },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ])
    .toArray()

  const period = moment(to).diff(moment(from), 'days')
  const total = result.length ? result[0].value : 0

  return {
    period,
    total,
    value: parseFloat((total / period).toFixed(3)),
  }
}

const getSummary = async ({ id }) => {
  const user = id !== 'all' && (await userCollection.get(id))
  const users = await userCollection.getAllExcept(id === 'all' ? null : id)

  if (!user && id !== 'all') {
    throw new Error('No such user')
  }

  const userSummary =
    id === 'all'
      ? { before: 0, after: 0 }
      : await getSummaryForUser({
          user,
          from: '2020-01-01',
        })
  const othersSummary = await Promise.all(
    users.map((user) => getSummaryForUser({ user, from: '2020-01-01' }))
  ).then((summaries) => ({
    before:
      summaries.map(({ before }) => before).reduce((sum, x) => sum + x, 0) /
      summaries.length,
    after:
      summaries.map(({ after }) => after).reduce((sum, x) => sum + x, 0) /
      summaries.length,
  }))

  return {
    user: userSummary,
    others: othersSummary,
  }
}

const getSummaryForUser = async ({ from, user }) => {
  const [before, after] = await Promise.all([
    getAverageStepsForUser({
      id: user._id.toString(),
      from: from,
      to: user.compareDate,
    }),
    getAverageStepsForUser({
      id: user._id.toString(),
      from: user.compareDate,
      to: moment().format(),
    }),
  ])

  return {
    before: before.value,
    after: after.value,
  }
}

const avg = (data) =>
  data.length > 0 ? data.reduce((sum, x) => sum + x) / data.length : 0

const getDailyAverages = async ({ id, from, to }) => {
  const user = await userCollection.get(id)
  const users = await userCollection.getAllExcept(id)
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  if (!user) {
    throw new Error('No such user')
  }

  const othersAverages = await Promise.all(
    users.map((user) => getDays({ id: user._id.toString(), from, to }))
  ).then((userData) => calculateDailyAverages(userData, dates))

  const userDays = await getDays({
    id: user._id.toString(),
    from,
    to,
  })
  const userAverages = calculateDailyAverages([userDays], dates)

  return {
    userDays: userAverages,
    otherDays: othersAverages,
  }
}

const calculateDailyAverages = (users, dates) =>
  dates.map((date) => ({
    date,
    avg: avg(
      users
        .map(({ result }) =>
          result.filter(({ key }) => key === date).map(({ value }) => value)
        )
        .flat()
    ),
  }))

const getLastUpload = async ({ id }) =>
  collection.findOne({ id }, { sort: { date: -1 } })

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  // steps
  save,
  getAverageHour,
  getHours,
  getDailyAverages,
  getSummary,
  getLastUpload,
}
