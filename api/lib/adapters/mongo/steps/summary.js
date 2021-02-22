let collection
const moment = require('moment')
const { FROM_DATE, BEFORE_END_DATE } = require('../../../constants')
const userCollection = require('../users')

const getQuery = ({ id, from, to, weekDays }) => {
  const query = {
    date: {
      $gte: new Date(from),
      $lt: new Date(to),
    },
  }
  if (weekDays !== undefined) {
    query['day'] = { $in: weekDays ? [1, 2, 3, 4, 5] : [0, 6] }
  }
  if (id !== 'all') {
    query['id'] = id
  }

  return query
}

const queryForPeriods = ({ id, periods, weekDays }) => {
  const query = {
    $or: periods.map(({ from, to }) => ({
      date: {
        $gte: new Date(from),
        $lt: new Date(to),
      },
    })),
  }
  if (weekDays !== undefined) {
    query['day'] = { $in: weekDays ? [1, 2, 3, 4, 5] : [0, 6] }
  }
  if (id !== 'all') {
    query['id'] = id
  }

  return query
}

const daysInPeriods = (periods) => {
  return periods.reduce((total, period) => {
    const days = moment(period.to).diff(moment(period.from), 'days')
    return total + days
  }, 0)
}

const getAverageStepsForUser = async ({ id, periods }) => {
  const result = await collection
    .aggregate([
      {
        $match: queryForPeriods({ id, periods }),
      },
      {
        $group: {
          _id: 'total',
          value: { $sum: '$value' },
        },
      },
    ])
    .toArray()

  const days = daysInPeriods(periods)
  let total = result.length ? result[0].value : 0

  return {
    days,
    total,
    value: parseInt(total / days),
  }
}

const getUserPeriods = (user, initialDataDate, latestDataDate) => {
  if (user.beforePeriods && user.afterPeriods) {
    return [user.beforePeriods, user.afterPeriods]
  }

  const beforePeriods = [
    {
      from: moment(initialDataDate).isAfter(FROM_DATE)
        ? initialDataDate
        : FROM_DATE,
      to: user.compareDate ? user.compareDate : BEFORE_END_DATE,
    },
  ]
  const afterPeriods = [
    {
      from: user.compareDate ? user.compareDate : BEFORE_END_DATE,
      to: latestDataDate,
    },
  ]

  return [beforePeriods, afterPeriods]
}

const getSummaryForUser = async ({ from, to, id }) => {
  const user = await userCollection.get(id)
  const [beforePeriods, afterPeriods] = getUserPeriods(user, from, to)

  const [before, after] = await Promise.all([
    getAverageStepsForUser({
      id,
      periods: beforePeriods,
    }),
    getAverageStepsForUser({
      id,
      periods: afterPeriods,
    }),
  ])

  return {
    before: before.value,
    after: after.value,
  }
}

module.exports = {
  init: (c) => {
    collection = c
  },
  getSummaryForUser,
}
