require('dotenv').config()

const fs = require('fs')
const { MongoClient, ObjectId } = require('mongodb')
let caBundle = fs.readFileSync(
  `${__dirname}/lib/adapters/mongo/rds-combined-ca-bundle.pem`
)
const DB_NAME = 'coronamovement'
const LIMIT = 2500
let total = 0
let prodDB, localDB

const syncDocs = async (collection, offset = 0) => {
  total += LIMIT
  const res = await prodDB
    .collection(collection)
    .find({})
    .limit(LIMIT)
    .skip(offset * LIMIT)
    .toArray()
  console.log('sync, ', res.length, 'total, ', total)
  if (res.length > 0) {
    await localDB.collection(collection).insertMany(res)

    return syncDocs(collection, offset + 1)
  }
}

const run = async () => {
  const prodClient = await MongoClient.connect(
    process.env.MIGRATION_CONNECT_TO,
    {
      ssl: true,
      sslValidate: false,
      sslCA: caBundle,
    }
  )
  prodDB = prodClient.db(DB_NAME)
  const localClient = await MongoClient.connect(process.env.CONNECT_TO, {})
  localDB = localClient.db(DB_NAME)

  const docs = await localDB.collection('allUser').find().toArray()
  await prodDB.collection('allUser').insertMany(docs)

  // await syncDocs('users')
  // await syncDocs('analytics')

  console.log('all done!')
}

const migrateUser = async (db, mongo, userId) => {
  const user = await db.collection('users').findOne({ _id: ObjectId(userId) })
  await mongo.insertUser(user)

  const steps = await db.collection('steps').find({ id: userId }).toArray()
  console.log('steps', steps.length)

  await mongo.insertSteps(steps)
}

run()
