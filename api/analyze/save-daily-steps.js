require('dotenv').config()

const elastic = require('../lib/adapters/elastic/index')
const mongo = require('../lib/adapters/mongo/index')
const userUtils = require('./user-utils')
const { promiseSeries } = require('./utils')

const saveUserSteps = async (user) => {
  const days = await mongo.getDaysForUser({ id: user._id.toString() })
  const dataPoints = days.map((d) => ({
    ...d,
    id: user._id.toString(),
    created: user.created,
    ageRange: user.ageRange,
    gender: user.gender,
    country: user.country,
    dataSource: user.dataSource,
    stepsChange: user.stepsChange,
  }))
  console.log('user', dataPoints.length)

  await elastic.saveDailySteps(dataPoints)
}

const run = async (db) => {
  console.log('save-daily-steps: start')
  localDB = db
  userUtils.init(localDB)

  try {
    const users = await userUtils.getUsers()
    promiseSeries(users, saveUserSteps)
  } catch (e) {
    console.log(e)
  }

  console.log('save-daily-steps: done')
}

module.exports = run
