const fs = require('fs')
const { MongoClient } = require('mongodb')
const moment = require('moment')
const { getBusinessDaysBetween } = require('../../utils/date')

let caBundle = fs.readFileSync(`${__dirname}/rds-combined-ca-bundle.pem`)
const DB_NAME = 'coronamovement'
const COLLECTION_NAME = 'steps'
const options =
  process.env.NODE_ENV === 'production'
    ? {
        ssl: true,
        sslCA: caBundle,
      }
    : {}

let cachedConnection

const run = async (func, data) => {
  let client = cachedConnection ? cachedConnection : null
  if (!client) {
    client = await MongoClient.connect(process.env.CONNECT_TO, options)
    cachedConnection = client
  }
  const collection = client.db(DB_NAME).collection(COLLECTION_NAME)

  const res = await func(collection, data)
  return res
}

const createIndex = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO, options)
  const db = client.db(DB_NAME)
  await db.createCollection(COLLECTION_NAME)
  client.close()
}

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

const getAverageHour = async (collection, { id, from, to, weekDays }) => {
  const daysDiff = moment(to).diff(moment(from), 'days')
  const weekdayDiff = getBusinessDaysBetween(from, to)
  const weekendDiff = daysDiff - weekdayDiff

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

module.exports = {
  createIndex,
  save: (payload) => run(insert, payload),
  getAverageHour: (payload) => run(getAverageHour, payload),
}
