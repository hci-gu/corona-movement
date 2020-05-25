const { MongoClient } = require('mongodb')

const DB_NAME = 'coronamovement'
const COLLECTION_NAME = 'steps'

const run = async (func, data) => {
  const client = await MongoClient.connect(process.env.CONNECT_TO)
  const collection = client.db(DB_NAME).collection(COLLECTION_NAME)

  const res = await func(collection, data)
  client.close()
  return res
}

const createIndex = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO)
  const db = client.db(DB_NAME)
  await db.createCollection(COLLECTION_NAME)
  client.close()
}

const insert = async (collection, { id, dataPoints, offset }) => {
  await collection.insertMany(
    dataPoints.map((point) => ({
      ...point,
      date: new Date(point.date),
      date_from: new Date(point.date_from),
      date_to: new Date(point.date_to),
    }))
  )
}

const getAverageHour = async (collection, { id, from, to, weekDays }) => {
  const result = (
    await collection
      .aggregate([
        {
          $match: {
            id,
            date: {
              $gte: new Date(from),
              $lte: new Date(to),
            },
            day: { $in: weekDays ? [1, 2, 3, 4, 5] : [0, 6] },
          },
        },
        {
          $group: {
            _id: {
              $hour: '$date',
            },
            value: { $avg: '$value' },
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

module.exports = {
  createIndex,
  save: (payload) => run(insert, payload),
  getAverageHour: (payload) => run(getAverageHour, payload),
}
