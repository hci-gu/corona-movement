require('dotenv').config()

const { MongoClient } = require('mongodb')
const elastic = require('../lib/adapters/elastic/index')
const mongo = require('../lib/adapters/mongo/index')

const saveAvgDaySteps = require('./save-avg-day-steps')
const saveUsers = require('./save-users')
const saveDailySteps = require('./save-daily-steps')

const run = async () => {
  const localClient = await MongoClient.connect(process.env.CONNECT_TO, {})
  const localDB = localClient.db('coronamovement')
  await mongo.inited()
  await elastic.createIndex()

  // users
  // await saveUsers(localDB)

  // average daily steps hour breakdown
  // await saveAvgDaySteps(localDB)

  // all days for users
  await saveDailySteps(localDB)

  // save steps
}

run()
