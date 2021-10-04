const moment = require('moment')

const SETTINGS = {
  periodUnit: 'months',
  minPeriodBefore: 3,
  minPeriodAfter: 3,
  minDataPoints: 75,
}

const isWeekend = (date) => {
  const day = moment(date).day()
  return day === 0 || day === 6
}

const createDateMapBetweenDates = (from, to) => {
  const days = to.diff(from, 'days')
  const map = {}
  Array.from({ length: days }).forEach((_, i) => {
    const date = moment(from).add(i, 'days').format('YYYY-MM-DD')
    map[date] = 0
  })
  return map
}

const numberOfDaysBetweenDates = (from, to, excludeWeekends = true) => {
  let count = 0
  const days = to.diff(from, 'days')
  Array.from({ length: days }).forEach((_, i) => {
    const date = moment(from).add(i, 'days')
    // if (!isWeekend(date)) count++
    count++
  })
  return count
}

const datesForUser = (user) => {
  const compareDate =
    user.afterPeriods && user.afterPeriods.length
      ? user.afterPeriods[0].from
      : user.compareDate
  // const from = user.
  return [
    moment(compareDate).subtract(SETTINGS.minPeriodBefore, SETTINGS.periodUnit),
    moment(compareDate).add(SETTINGS.minPeriodAfter, SETTINGS.periodUnit),
    moment(compareDate),
  ]
}

const createHourMap = () =>
  Array.from({ length: 24 })
    .map((_, i) => i)
    .reduce((map, i) => {
      const key = i > 9 ? `${i}` : `0${i}`
      map[key] = { value: 0, count: 0 }
      return map
    }, {})

module.exports = {
  createHourMap,
  datesForUser,
  isWeekend,
  numberOfDaysBetweenDates,
  createDateMapBetweenDates,
  SETTINGS,
}
