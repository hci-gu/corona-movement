require('dotenv').config()

const fs = require('fs')
const { MongoClient } = require('mongodb')
let caBundle = fs.readFileSync(
  `${__dirname}/lib/adapters/mongo/rds-combined-ca-bundle.pem`
)
const DB_NAME = 'coronamovement'
const COLLECTION_NAME = 'users'

const mongo = require('./lib/adapters/mongo/index')

const syncDocs = async (collection, offset) => {
  const limit = 2500
  const res = await collection
    .find({})
    .limit(limit)
    .skip(offset * limit)
    .toArray()
  console.log('sync', res.length)
  if (res.length > 0) {
    try {
      await mongo.createUser(res)
    } catch (e) {}

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
