const aggregatedStepsCollection = require('../../lib/adapters/mongo/aggregatedSteps')
// const calendarMonth = require('./calendar-month')
const userPeriods = require('./user-periods')
const beforeAfter = require('./before-after')

let localDB
const init = (db) => {
  localDB = db
}

const getStepsForUser = async (user) => {
  const result = (
    await aggregatedStepsCollection.getSteps({ id: user._id.toString() })
  ).result

  return result
}

const createRows = async (offset = 0, limit = 100) => {
  let users = await localDB
    .collection('users')
    .find()
    .limit(limit)
    .skip(offset * limit)
    .toArray()

  const usersWithSteps = await Promise.all(
    users.map(async (user) => {
      const steps = await getStepsForUser(user)
      return {
        steps,
        user,
      }
    })
  )

  const rows = usersWithSteps.map(({ user, steps }) => {
    try {
      const userWithRows = userPeriods.rowForUser(user, steps)
      return userWithRows
    } catch (e) {
      console.log(e)
    }
    return null
  })

  return rows.filter((u) => !!u && u.rows && u.rows.length)
}

module.exports = {
  createRows,
  init,
}
