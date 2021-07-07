const mongo = require('../lib/adapters/mongo/index')
const {
  allDaysForUser,
  translateEducation,
  translateGender,
  translateAgeRange,
} = require('./utils')

let localDB
const init = (db) => {
  localDB = db
}

const createAggregatedUsers = (users) => {
  return Promise.all(
    users.map(async (u) => {
      const userId = u._id.toString()
      let days = await mongo.getDays({ id: userId })
      if (days.result === null) {
        days = await mongo.saveAggregatedDays({ id: userId })
      }
      const daysIncludingEmptyDays = allDaysForUser(days)
      let compareDate = u.compareDate
      if (!compareDate && u.afterPeriods && u.afterPeriods.length === 1) {
        compareDate = u.afterPeriods[0].from
      }

      return {
        ...u,
        compareDate,
        ageRange: translateAgeRange(u.ageRange),
        gender: translateGender(u.gender),
        education: translateEducation(u.education),
        days: daysIncludingEmptyDays,
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
  const aggregatedUsers = await createAggregatedUsers(users)

  await Promise.all(aggregatedUsers.map((u) => mongo.saveAggregatedUser(u)))
}

module.exports = {
  createAggregatedUsers,
  saveUsers,
  init,
}
