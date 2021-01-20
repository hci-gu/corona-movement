const mongo = require('../lib/adapters/mongo/index')
const {
  getPercentageChange,
  userEstimatedWrong,
  estimatedHigherThanResult,
  estimatedLowerThanResult,
} = require('./utils')

let localDB
const init = (db) => {
  localDB = db
}

const filterUser = (u) =>
  u.stepsBefore > 0 &&
  u.stepsAfter > 0 &&
  u.stepDataPoints > 2500 &&
  u.ageRange != undefined

const mapUsers = (users) => {
  return Promise.all(
    users.map(async (u) => {
      const summary = await mongo.getSummary({ id: u._id.toString() })
      const stepDataPoints = await stepDataPointCountForUser(u)

      const { before, after } = summary.user
      const stepsChange = getPercentageChange(before, after)
      const estimatedWrong = userEstimatedWrong(u.stepsEstimate, stepsChange)

      return {
        ...u,
        stepsChange,
        stepsBefore: before,
        stepsAfter: after,
        stepDataPoints,
        estimatedWrong,
        estimatedHigher: estimatedHigherThanResult(
          u.stepsEstimate,
          stepsChange
        ),
        estimatedLower: estimatedLowerThanResult(u.stepsEstimate, stepsChange),
      }
    })
  )
}

const stepDataPointCountForUser = (u) => {
  return localDB.collection('steps').find({ id: u._id.toString() }).count()
}

const getUsers = async () => {
  const users = await localDB.collection('users').find().toArray()
  const _users = users.filter((u) => u.stepsEstimate != undefined)
  const mapped = await mapUsers(_users)

  return mapped.filter(filterUser)
}

module.exports = {
  mapUsers,
  getUsers,
  init,
}
