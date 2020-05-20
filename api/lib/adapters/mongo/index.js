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
  await collection.insertMany(dataPoints)
}

const getAverageHour = async (collection, { id, from, to, weekDays }) => {
  const result = await collection
    .aggregate([
      {
        $bucketAuto: {
          groupBy: '$time',
          buckets: 24,
          output: {
            value: { $avg: '$value' },
          },
        },
      },
    ])
    .toArray()
  return {
    from,
    to,
    result,
  }
}

module.exports = {
  createIndex,
  save: (payload) => run(insert, payload),
  getAverageHour: (payload) => run(getAverageHour, payload),
}
