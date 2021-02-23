const { countCertainDays } = require('../../../utils/date')
const { queryForPeriods, daysInPeriods } = require('./utils')
let collection

const getAverageHoursForUserPeriods = async ({ id, periods }) => {
  const result = await collection
    .aggregate([
      {
        $match: queryForPeriods({ id, periods }),
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%H',
              date: '$date',
              timezone: 'Europe/Stockholm',
            },
          },
          value: { $sum: '$value' },
        },
      },
    ])
    .toArray()

  const numDays = daysInPeriods(periods)
  const map = result.reduce((acc, curr) => {
    acc[parseInt(curr._id)] = {
      hour: parseInt(curr._id),
      value: Math.round(curr.value / numDays),
    }
    return acc
  }, {})

  return Array.from({ length: 24 }).map((_, i) => ({
    hour: i,
    value: 0,
    ...map[i],
  }))
}

const getHoursForDay = async ({
  id,
  day,
  from,
  to,
  timezone = 'Europe/Stockholm',
}) => {
  const result = await collection
    .aggregate([
      {
        $match: {
          date: {
            $gte: new Date(from),
            $lt: new Date(to),
          },
          day,
          id,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%H',
              date: '$date',
              timezone,
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

  const numDays = countCertainDays([day], new Date(from), new Date(to))
  const map = result.reduce((acc, curr) => {
    acc[parseInt(curr._id)] = {
      hour: parseInt(curr._id),
      value: Math.round(curr.value / numDays),
    }
    return acc
  }, {})

  return Array.from({ length: 24 }).map((_, i) => ({
    hour: i,
    value: 0,
    ...map[i],
  }))
}

const getDaysForUser = async ({ id, timezone = 'Europe/Stockholm' }) => {
  const result = await collection
    .aggregate([
      {
        $match: {
          id,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$date',
              timezone,
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

  return result.map((d) => ({
    date: d._id,
    value: d.value,
  }))
}

module.exports = {
  init: (c) => {
    collection = c
  },
  getHoursForDay,
  getDaysForUser,
  getAverageHoursForUserPeriods,
}
