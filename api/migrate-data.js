require('dotenv').config()

const fs = require('fs')
const { MongoClient } = require('mongodb')
let caBundle = fs.readFileSync(
  `${__dirname}/lib/adapters/mongo/rds-combined-ca-bundle.pem`
)
const DB_NAME = 'coronamovement'
const COLLECTION_NAME = 'steps'

const { transformHealthData } = require('./lib/adapters/db')

const mongo = require('./lib/adapters/mongo/index')
const elastic = require('./lib/adapters/elastic/index')

let total = 0

const syncDocs = async (collection, offset) => {
  const limit = 2500
  total += limit
  const res = await collection
    .find({})
    .limit(limit)
    .skip(offset * limit)
    .toArray()
  console.log('sync, ', res.length, 'totalt, ', total)
  if (res.length > 0) {
    try {
      // await mongo.saveSteps(res)
      await elastic.save(
        res.map((d) => {
          return {
            value: d.value,
            date: new Date(d.date),
            date_from: new Date(d.date_from),
            date_to: new Date(d.date_to),
            duration: d.duration,
            day: d.day,
            time: d.time,
            id: d.id,
          }
        })
      )
    } catch (e) {
      console.log(e)
    }

    return syncDocs(collection, offset + 1)
  }
}

const run = async () => {
  const client = await MongoClient.connect(process.env.MIGRATION_CONNECT_TO, {
    ssl: true,
    sslValidate: false,
    sslCA: caBundle,
  })
  const collection = client.db(DB_NAME).collection(COLLECTION_NAME)
  await syncDocs(collection, 0)

  console.log('all done!')
}

run()
