const stepsCollection = require('../../lib/adapters/mongo/steps')
const aggregatedStepsCollection = require('../../lib/adapters/mongo/aggregatedSteps')
const moment = require('moment')
const { translateGender, translateAgeRange } = require('../utils')
const {
  SETTINGS,
  datesForUser,
  createHourMap,
  isWeekend,
  createDateMapBetweenDates,
} = require('./utils')

let localDB
const init = (db) => {
  localDB = db
}

const getAverageDayForHours = (hours, dayCount) => {
  const hoursMap = hours.reduce((map, { hour, value }) => {
    map[hour] = {
      value: map[hour].value + value,
    }
    return map
  }, createHourMap())

  return Object.keys(hoursMap).map((key) => ({
    hour: key,
    value: hoursMap[key].value / dayCount,
  }))
}

const daysWithData = (from, to, hours) => {
  const dateMap = createDateMapBetweenDates(from, to)

  const dayMap = hours.reduce((map, { value, date }) => {
    if (!map[date]) map[date] = 0
    map[date] = map[date] + value
    return map
  }, dateMap)

  return Object.keys(dayMap)
    .map((key) => ({
      date: key,
      value: dateMap[key],
    }))
    .filter(({ value }) => value > 0)
}

const averageDayForUser = (user, hours) => {
  const [from, to, compareDate] = datesForUser(user)

  const hoursBefore = hours.filter(
    ({ date }) => from.isBefore(date) && compareDate.isAfter(date)
  )
  const hoursAfter = hours.filter(
    ({ date }) => compareDate.isBefore(date) && to.isAfter(date)
  )

  const daysBefore = daysWithData(from, compareDate, hoursBefore)
  const daysAfter = daysWithData(compareDate, to, hoursAfter)

  if (
    daysBefore.length < SETTINGS.minDataPoints ||
    daysAfter.length < SETTINGS.minDataPoints
  ) {
    throw new Error('User does not have enough data')
  }

  const dayBefore = getAverageDayForHours(hoursBefore, daysBefore.length)
  const dayAfter = getAverageDayForHours(hoursAfter, daysAfter.length)

  return [
    ...dayBefore.map((r) => ({ ...r, series: 'before' })),
    ...dayAfter.map((r) => ({ ...r, series: 'after' })),
  ]
}

const rowForUser = async (user) => {
  const userId = user._id.toString()
  const result = (await aggregatedStepsCollection.getSteps({ id: userId }))
    .result
  const hours = result.map(({ key, value }) => {
    const [date, hour] = key.split(' ')
    // id, gender, ageRange, cmpDate, date, hour, value
    return { date, hour, value }
  })

  if (!hours.length) {
    throw new Error('User has no data')
  }

  const [, , compareDate] = datesForUser(user)
  const rows = averageDayForUser(user, hours)

  return {
    id: userId,
    gender: translateGender(user.gender),
    ageRange: translateAgeRange(user.ageRange),
    occupation: user.occupation,
    compareDate: compareDate.format('YYYY-MM-DD'),
    rows,
  }
}

const createRows = async (offset = 0, limit = 100) => {
  let users = await localDB
    .collection('users')
    .find()
    .limit(limit)
    .skip(offset * limit)
    .toArray()

  console.log('createRows', users.length)

  const rows = await Promise.all(
    users.map((u) => {
      return rowForUser(u).catch((e) => {
        console.log('abort, reason:', e.message)
        return null
      })
    })
  )

  return rows.filter((u) => !!u)
}

module.exports = {
  createRows,
  init,
}
