const moment = require('moment')
const { translateGender, translateAgeRange } = require('../utils')
const { averageDayForForPeriod, compareDateForUser } = require('./utils')

// same period for all users
const startDate = moment().startOf('month')
const periodsFromDateAndDirection = (date, length, back = false) => {
  return Array.from({ length }).map((_, i) => {
    if (back && i === 0) return
    const month = back
      ? moment(date).subtract(i, 'months')
      : moment(date).add(i, 'months')
    return {
      name: month.format('YYYY-MMMM'),
      from: moment
        .utc(moment.tz('Europe/Stockholm').format('YYYY-MM-DDTHH:mm:ss'))
        .toDate(),
      to: moment(month).add(1, 'months').toDate(),
    }
  })
}

const periods = [
  // ...periodsFromDateAndDirection(startDate, 12, true),
  ...periodsFromDateAndDirection(startDate, 45, true),
]
  .filter((x) => x)
  .sort((a, b) => a.from - b.from)

console.log(periods)

const rowForUser = (user, steps) => {
  const hours = steps.map(({ key, value }) => {
    const [date, hour] = key.split(' ')
    return { date, hour, value }
  })

  if (!hours.length) {
    throw new Error('User has no data')
  }

  const compareDate = compareDateForUser(user)
  let rows = []
  periods.forEach((period) => {
    try {
      rows = [...rows, ...averageDayForForPeriod(hours, period)]
    } catch (e) {}
  })

  if (!rows.length) {
    throw new Error('User has no data')
  }

  return {
    id: user._id.toString(),
    gender: translateGender(user.gender),
    ageRange: translateAgeRange(user.ageRange),
    occupation: user.occupation,
    compareDate: compareDate.format('YYYY-MM-DD'),
    stepsEstimate: user.stepsEstimate,
    rows,
  }
}

module.exports = {
  rowForUser,
}
