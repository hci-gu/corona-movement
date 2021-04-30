const mongo = require('../lib/adapters/mongo/index')
const {
  getPercentageChange,
  userEstimatedWrong,
  estimatedHigherThanResult,
  estimatedLowerThanResult,
  daysWithDataForUser,
  translateEducation,
  translateGender,
  translateAgeRange,
} = require('./utils')

let localDB
const init = (db) => {
  localDB = db
}

const createAggregatedUsers = (users, summariesMap) => {
  return Promise.all(
    users.map(async (u) => {
      const userId = u._id.toString()
      const summary = summariesMap[userId]
      const totalSteps = 0
      let days = await mongo.getDays({ id: userId })
      if (days.result === null) {
        days = await mongo.saveAggregatedDays({ id: userId })
      }
      const daysInfo = daysWithDataForUser(days)

      let before = null,
        after = null
      if (summary && summary.user) {
        before = summary.user.before
        after = summary.user.after
      }
      const stepsChange = getPercentageChange(before, after)
      const estimatedWrong = userEstimatedWrong(u.stepsEstimate, stepsChange)

      return {
        ...u,
        ageRange: translateAgeRange(u.ageRange),
        gender: translateGender(u.gender),
        education: translateEducation(u.education),
        stepsChange,
        stepsBefore: before,
        stepsAfter: after,
        daysWithData: daysInfo.daysWithData,
        missingDays: daysInfo.period - daysInfo.daysWithData,
        period: daysInfo.period,
        estimatedWrong,
        estimatedHigher: estimatedHigherThanResult(
          u.stepsEstimate,
          stepsChange
        ),
        estimatedLower: estimatedLowerThanResult(u.stepsEstimate, stepsChange),
        totalSteps,
        days: daysInfo.days,
        wfhPeriods: u.afterPeriods ? u.afterPeriods.length : 0,
      }
    })
  )
}

const saveUsers = async (offset = 0, limit = 100) => {
  const users = await localDB
    .collection('users')
    .find()
    .limit(limit)
    .skip(offset * limit)
    .toArray()
  const allSummariesMap = await mongo.getAllSummariesMap()
  const aggregatedUsers = await createAggregatedUsers(users, allSummariesMap)

  await Promise.all(aggregatedUsers.map((u) => mongo.saveAggregatedUser(u)))
}

module.exports = {
  createAggregatedUsers,
  saveUsers,
  init,
}
