const fs = require('fs')
const { MongoClient, ObjectId } = require('mongodb')
const moment = require('moment')
const { getBusinessDaysBetween } = require('../../utils/date')

let caBundle = fs.readFileSync(`${__dirname}/rds-combined-ca-bundle.pem`)
const DB_NAME = 'coronamovement'
const STEPS_COLLECTION = 'steps'
const USERS_COLLECTION = 'users'
const options =
  process.env.NODE_ENV === 'production'
    ? {
      ssl: true,
      sslValidate: false,
      sslCA: caBundle,
    }
    : {}

let cachedConnection

const run = async (func, data, collectionName = STEPS_COLLECTION) => {
  let client = cachedConnection ? cachedConnection : null
  if (!client) {
    client = await MongoClient.connect(process.env.CONNECT_TO, options)
    cachedConnection = client
  }
  const collection = client.db(DB_NAME).collection(collectionName)

  const res = await func(collection, data)
  return res
}

const createIndex = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO, options)
  const db = client.db(DB_NAME)
  await db.createCollection(STEPS_COLLECTION)
  await db.createCollection(USERS_COLLECTION)
  client.close()
}

const createUser = async (collection, { compareDate, division }) => {
  const result = await collection.insert({
    compareDate: new Date(compareDate),
    division,
  })
  return result.ops[0]
}

const getUser = async (collection, id) =>
  collection.findOne({ _id: ObjectId(id) })

const getAllUsersExcept = async (collection, id) =>
  collection.find({ _id: { $ne: ObjectId(id) } }).toArray()

const insert = async (collection, dataPoints) => {
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

const getAverageHour = async (collection, { id, from, to, weekDays }) => {
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

const getHours = async (collection, { id, from, to }) => {
  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)
  const weekendDiff = daysDiff - weekdayDiff

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

const getDays = async (collection, { id, from, to }) => {
  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)
  const weekendDiff = daysDiff - weekdayDiff

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

const getAverageStepsForUser = async (collection, { id, from, to }) => {
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

const getSummary = async (collection, { id }) => {
  const user = await run(getUser, id, USERS_COLLECTION)
  const users = await run(getAllUsersExcept, id, USERS_COLLECTION)

  if (!user) {
    throw new Error('No such user')
  }

  const userSummary = await getSummaryForUser(collection, {
    user,
    from: '2020-01-01',
  })
  const othersSummary = await Promise.all(
    users.map((user) =>
      getSummaryForUser(collection, { user, from: '2020-01-01' })
    )
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

const getSummaryForUser = async (collection, { from, user }) => {
  const [before, after] = await Promise.all([
    getAverageStepsForUser(collection, {
      id: user._id.toString(),
      from: from,
      to: user.compareDate,
    }),
    getAverageStepsForUser(collection, {
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

const getDailyAverages = async (collection, { id, from, to }) => {
  const user = await run(getUser, id, USERS_COLLECTION)
  const users = await run(getAllUsersExcept, id, USERS_COLLECTION)
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  if (!user) {
    throw new Error('No such user')
  }

  const othersAverages = await Promise.all(
    users.map((user) =>
      getDays(collection, { id: user._id.toString(), from, to })
    )
  ).then((userData) => calculateDailyAverages(userData, dates))

  const userDays = await getDays(collection, {
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

module.exports = {
  createIndex,
  save: (payload) => run(insert, payload),
  getAverageHour: (payload) => run(getAverageHour, payload),
  getHours: (payload) => run(getHours, payload),
  getDailyAverages: (payload) => run(getDailyAverages, payload),
  createUser: (payload) => run(createUser, payload, USERS_COLLECTION),
  getUser: (payload) => run(getUser, payload, USERS_COLLECTION),
  getSummary: async (payload) => run(getSummary, payload),
}
