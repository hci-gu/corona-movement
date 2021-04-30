const fs = require('fs')
const { MongoClient } = require('mongodb')
const userCollection = require('./users')
const stepsCollection = require('./steps')
const aggregatedStepsCollection = require('./aggregatedSteps')
const aggregatedUsersCollection = require('./aggregatedUsers')
const codesCollection = require('./codes')
const feedbackCollection = require('./feedback')
const analyticsCollection = require('./analytics')
const groupsCollection = require('./groups')
const allUserCollection = require('./allUser')

let caBundle = fs.readFileSync(`${__dirname}/rds-combined-ca-bundle.pem`)
let inited
const DB_NAME = process.env.DB_NAME ? process.env.DB_NAME : 'coronamovement'
const options =
  process.env.NODE_ENV === 'production'
    ? {
        ssl: true,
        sslValidate: false,
        sslCA: caBundle,
      }
    : {}

const init = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO, options)
  const db = client.db(DB_NAME)
  await Promise.all([
    userCollection.init(db),
    stepsCollection.init(db),
    aggregatedStepsCollection.init(db),
    aggregatedUsersCollection.init(db),
    codesCollection.init(db),
    feedbackCollection.init(db),
    analyticsCollection.init(db),
    groupsCollection.init(db),
    allUserCollection.init(db),
  ])
  inited = true
}

const getDB = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO, options)
  return client.db(DB_NAME)
}

module.exports = {
  // steps
  saveSteps: stepsCollection.save,
  getLastUpload: stepsCollection.getLastUpload,
  removeStepsForUser: stepsCollection.removeStepsForUser,
  getTotalSteps: stepsCollection.getTotalSteps,
  getTotalStepsForUser: stepsCollection.getTotalStepsForUser,
  insertSteps: stepsCollection.insertSteps,
  getAverageDayForPeriod: stepsCollection.getHoursForDay,
  getDaysForUser: stepsCollection.getDaysForUser,
  // aggregatedSteps
  saveAggregatedSteps: aggregatedStepsCollection.saveSteps,
  saveAggregatedSummary: aggregatedStepsCollection.saveSummary,
  saveAggregatedDays: aggregatedStepsCollection.saveDays,
  getHours: aggregatedStepsCollection.getSteps,
  getSummary: aggregatedStepsCollection.getSummary,
  getDays: aggregatedStepsCollection.getDays,
  getAllSummariesMap: aggregatedStepsCollection.getAllSummariesMap,
  getAllDaysMap: aggregatedStepsCollection.getAllDaysMap,
  // aggregatedUsers
  saveAggregatedUser: aggregatedUsersCollection.saveUser,
  getAggregatedUsers: aggregatedUsersCollection.getUsers,
  clearAggregatedUsers: aggregatedUsersCollection.clearUsers,
  // users
  createUser: userCollection.create,
  getUser: userCollection.get,
  updateUser: userCollection.update,
  removeUser: userCollection.remove,
  insertUser: userCollection.insert,
  getAllUsers: () => userCollection.getAllExcept(),
  userCount: userCollection.count,
  joinGroup: userCollection.joinGroup,
  leaveGroup: userCollection.leaveGroup,
  // codes
  codeExists: codesCollection.codeExists,
  // analytics
  saveAnalyticsEvent: analyticsCollection.saveEvent,
  removeAnalyticsForUser: analyticsCollection.removeAnalyticsForUser,
  analyticsCount: analyticsCollection.count,
  inited: async () => {
    if (!inited) await init()
    return true
  },
  // groups
  getGroup: groupsCollection.get,
  createGroup: groupsCollection.create,
  getGroupFromCode: groupsCollection.getGroupFromCode,
  // all
  getAllHours: allUserCollection.getHours,
  getAllDays: allUserCollection.getDays,
  getAllSummary: allUserCollection.getSummary,
  saveAllUser: allUserCollection.save,
  getDB,
}
