const fs = require('fs')
const { MongoClient } = require('mongodb')
const userCollection = require('./users')
const stepsCollection = require('./steps')
const aggregatedStepsCollection = require('./aggregatedSteps')
const codesCollection = require('./codes')
const feedbackCollection = require('./feedback')
const analyticsCollection = require('./analytics')
const groupsCollection = require('./groups')

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
    codesCollection.init(db),
    feedbackCollection.init(db),
    analyticsCollection.init(db),
    groupsCollection.init(db),
  ])
  inited = true
}

module.exports = {
  // steps
  saveSteps: stepsCollection.save,
  getLastUpload: stepsCollection.getLastUpload,
  removeStepsForUser: stepsCollection.removeStepsForUser,
  getTotalSteps: stepsCollection.getTotalSteps,
  insertSteps: stepsCollection.insertSteps,
  // aggregatedSteps
  saveAggregatedSteps: aggregatedStepsCollection.saveSteps,
  saveAggregatedSummary: aggregatedStepsCollection.saveSummary,
  getHours: aggregatedStepsCollection.getSteps,
  getSummary: aggregatedStepsCollection.getSummary,
  // users
  createUser: userCollection.create,
  getUser: async (id) => {
    const user = await userCollection.get(id)
    if (!user) {
      return null
    }
    const date = await aggregatedStepsCollection.shouldPopulateUntilDate(id)
    if (date) {
      user.initialDataDate = new Date(date.format())
    }
    return user
  },
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
}
