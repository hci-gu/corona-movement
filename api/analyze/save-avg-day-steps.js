require('dotenv').config()

const moment = require('moment')
const elastic = require('../lib/adapters/elastic/index')
const mongo = require('../lib/adapters/mongo/index')
const userUtils = require('./user-utils')
const { promiseSeries } = require('./utils')

const getUserDay = async (user, day, before) => {
  const lastUpload = await mongo.getLastUpload({ id: user._id.toString() })
  const from = before ? '2020-01-01' : user.compareDate
  const to = before
    ? user.compareDate
    : moment(lastUpload.date).subtract(1, 'day').endOf('day').format()

  return (
    await mongo.getAverageDayForPeriod({
      id: user._id.toString(),
      from,
      to,
      day,
    })
  ).map((d) => ({
    ...d,
    day,
    id: user._id.toString(),
    ageRange: user.ageRange,
    gender: user.gender,
    country: user.country,
    dataSource: user.dataSource,
    isAfter: !before,
    stepsChange: user.stepsChange,
  }))
}

const saveUserSteps = async (user) => {
  const days = [0, 1, 2, 3, 4, 5, 6]

  const weekBefore = await Promise.all(
    days.map((i) => getUserDay(user, i, true))
  )
  const weekAfter = await Promise.all(
    days.map((i) => getUserDay(user, i, false))
  )
  const dataPoints = [...weekBefore, ...weekAfter].reduce((acc, curr) => {
    return [...acc, ...curr]
  }, [])
  await elastic.saveAvgSteps(dataPoints)
}

const run = async (db) => {
  console.log('save-avg-day-steps: start')
  localDB = db
  userUtils.init(localDB)

  const users = await userUtils.getUsers()
  promiseSeries(users, saveUserSteps)

  console.log('save-avg-day-steps: done')
}

module.exports = run
