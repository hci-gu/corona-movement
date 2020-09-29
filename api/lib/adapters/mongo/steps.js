const { ObjectId } = require('mongodb')
const moment = require('moment')
const userCollection = require('./users')
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

const getHours = async ({ id, from, to }) => {
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
    result,
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

const getSummaryForUser = async ({ from, id }) => {
  const user = await userCollection.get(id)

  const [before, after] = await Promise.all([
    getAverageStepsForUser({
      id,
      from: from,
      to: user.compareDate,
    }),
    getAverageStepsForUser({
      id,
      from: user.compareDate,
      to: moment(user.endDate ? user.endDate : undefined).format(),
    }),
  ])

  return {
    before: before.value,
    after: after.value,
  }
}

const getLastUpload = async ({ id }) =>
  collection.findOne({ id }, { sort: { date: -1 } })

const removeStepsForUser = async (id) => collection.deleteMany({ id })

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
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
  getSummaryForUser,
  getLastUpload,
  removeStepsForUser,
}
