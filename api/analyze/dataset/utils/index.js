const moment = require('moment')
const SETTINGS = require('./settings')
const {
  isWeekend,
  createDateMapBetweenDates,
  createHourMap,
} = require('./date')

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

const averageDayForForPeriod = (data, period) => {
  const hours = data.filter(({ date }) => {
    const check = new Date(date)
    return check > period.from && check < period.to && !isWeekend(check)
  })
  const days = daysWithData(period.from, period.to, hours)

  if (days.length < SETTINGS.minDataPoints) {
    throw new Error('User does not have enough data')
  }

  const day = getAverageDayForHours(hours, days.length)

  return day.map((r) => ({ ...r, series: period.name }))
}

const periodsForUser = (compareDate, length) => {
  const beforePeriods = Array.from({ length }).map((_, i) => ({
    name: moment('2020-03-16')
      .subtract(i + 1, SETTINGS.periodUnit)
      .format('YYYY-MM-DD'),
    from: moment(compareDate)
      .subtract(i + 1, SETTINGS.periodUnit)
      .toDate(),
    to: moment(compareDate).subtract(i, SETTINGS.periodUnit).toDate(),
  }))
  // const from = moment(compareDate).subtract(1, 'month').toDate()
  // const beforePeriod = {
  //   name: '2020-02-16',
  //   from,
  //   to: moment(compareDate).toDate(),
  // }

  const afterPeriods = Array.from({ length }).map((_, i) => ({
    // name: `${SETTINGS.periodUnit}-${i + 1}-after`,
    name: moment('2020-03-16').add(i, SETTINGS.periodUnit).format('YYYY-MM-DD'),
    from: moment(compareDate).add(i, SETTINGS.periodUnit).toDate(),
    to: moment(compareDate)
      .add(i + 1, SETTINGS.periodUnit)
      .toDate(),
  }))

  return [
    ...beforePeriods.reverse(),
    // beforePeriod,
    ...afterPeriods,
  ]
}

const compareDateForUser = (user) => {
  const compareDate =
    user.afterPeriods && user.afterPeriods.length
      ? user.afterPeriods[0].from
      : user.compareDate

  return moment(compareDate)
}

module.exports = {
  compareDateForUser,
  periodsForUser,
  averageDayForForPeriod,
}
