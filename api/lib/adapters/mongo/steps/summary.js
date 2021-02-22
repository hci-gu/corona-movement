let collection
const moment = require('moment')
const { BEFORE_END_DATE } = require('../../../constants')
const userCollection = require('../users')

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

const getUserPeriods = (user, latestDataDate) => {
  const beforePeriods = userCollection.beforePeriodsForUser(user)

  if (user.afterPeriods) {
    return [
      beforePeriods,
      user.afterPeriods.map((p) => ({
        from: p.from,
        to: p.to ? p.to : moment().format('YYYY-MM-DD'),
      })),
    ]
  }

  const afterPeriods = [
    {
      from: user.compareDate ? user.compareDate : BEFORE_END_DATE,
      to: latestDataDate,
    },
  ]

  return [beforePeriods, afterPeriods]
}

const getSummaryForUser = async ({ id, from, to }) => {
  const user = await userCollection.get(id)
  const [beforePeriods, afterPeriods] = getUserPeriods(user, to)

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
