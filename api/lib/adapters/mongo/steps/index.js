const moment = require('moment')
const analyze = require('./analyze')
const summary = require('./summary')
const COLLECTION = 'steps'
let collection

const saveSingle = async (dataPoint) => {
  try {
    await collection.insertOne(dataPoint)
  } catch (e) {
    if (e.code === 11000) {
      await collection.update(
        {
          id: dataPoint.id,
          date: dataPoint.date,
          value: { $lt: dataPoint.value },
        },
        { $set: { value: dataPoint.value, platform: dataPoint.platform } }
      )
    }
  }
}

const save = async (dataPoints) => {
  try {
    await collection.insertMany(dataPoints)
  } catch (e) {
    if (e.code === 11000) {
      await Promise.all(dataPoints.map(saveSingle))
    }
  }
}

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

const getQueryForPeriods = ({ id, periods }) => {
  const query = {
    $or: [
      periods.map(({ from, to }) => ({
        date: {
          $gte: new Date(from),
          $lt: new Date(to),
        },
      })),
    ],
  }
}

const getHours = async ({ id, from, to, timezone = 'Europe/Stockholm' }) => {
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
  ).map((o) => {
    return {
      ...o,
      key: o._id,
    }
  })

  return {
    from,
    to,
    result,
  }
}

const getLastUpload = ({ id }) =>
  collection.findOne({ id }, { sort: { date: -1 } })

const getFirstUpload = ({ id }) =>
  collection.findOne({ id }, { sort: { date: 1 } })

const removeStepsForUser = async (id) => collection.deleteMany({ id })

const getTotalSteps = async () => {
  const result = await collection
    .aggregate([
      {
        $group: {
          _id: 'total',
          value: { $sum: '$value' },
        },
      },
    ])
    .toArray()

  return result[0].value
}

const insertSteps = (steps) => collection.insertMany(steps)

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
    summary.init(collection)
  },
  collection,
  save: (dataPoints) =>
    save(
      dataPoints.map((point) => ({
        ...point,
        date: new Date(point.date),
        dateFrom: new Date(point.dateFrom),
      }))
    ),
  getHours,
  getFirstUpload,
  getLastUpload,
  removeStepsForUser,
  getTotalSteps,
  insertSteps,
  // summary for user
  getSummaryForUser: summary.getSummaryForUser,
  // analyze ( not used by app )
  getHoursForDay: analyze.getHoursForDay,
  getDaysForUser: analyze.getDaysForUser,
}
