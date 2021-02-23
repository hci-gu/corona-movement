let collection
const { queryForPeriods, daysInPeriods, getUserPeriods } = require('./utils')
const userCollection = require('../users')

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
