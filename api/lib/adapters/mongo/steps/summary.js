let collection
const moment = require('moment')
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

const getAverageStepsForUser = async ({ id, from, to, daysToPeriod = 0 }) => {
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
    ])
    .toArray()

  const period = moment(to).diff(moment(from), 'days') + daysToPeriod
  let total = result.length ? result[0].value : 0

  return {
    period,
    total,
    value: parseInt(total / period),
  }
}

const getSummaryForUser = async ({ from, to, id }) => {
  const user = await userCollection.get(id)

  const [before, after] = await Promise.all([
    getAverageStepsForUser({
      id,
      from,
      to: user.compareDate,
      daysToPeriod: 0,
    }),
    getAverageStepsForUser({
      id,
      from: user.compareDate,
      to: moment(to).format(),
      daysToPeriod: -1,
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
