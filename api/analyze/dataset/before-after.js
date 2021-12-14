const moment = require('moment')
const { translateGender, translateAgeRange } = require('../utils')
const { averageDayForForPeriod, compareDateForUser } = require('./utils')
const SETTINGS = require('./utils/settings')

const periodsForUser = (compareDate) => {
  return [
    {
      name: 'before',
      from: moment(compareDate)
        .subtract(SETTINGS.periodBefore, SETTINGS.periodUnit)
        .toDate(),
      to: moment(compareDate)
        .add(SETTINGS.periodAfter, SETTINGS.periodUnit)
        .toDate(),
    },
    {
      name: 'after',
      from: moment(compareDate).toDate(),
      to: moment(compareDate)
        .add(SETTINGS.periodAfter, SETTINGS.periodUnit)
        .toDate(),
    },
  ]
  // .map(({ name, from, to }) => ({
  //   name,
  //   from: moment(from).subtract(1, 'year').toDate(),
  //   to: moment(to).subtract(1, 'year').toDate(),
  // }))
}

const rowForUser = (user, steps) => {
  const hours = steps.map(({ key, value }) => {
    const [date, hour] = key.split(' ')
    return { date, hour, value }
  })

  if (!hours.length) {
    throw new Error('User has no data')
  }

  const compareDate = compareDateForUser(user)
  const periods = periodsForUser(compareDate)
  let rows = []
  periods.forEach((period) => {
    try {
      rows = [...rows, ...averageDayForForPeriod(hours, period)]
    } catch (e) {
      throw new Error('User requires both periods to have data')
    }
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
    dataSource: user.dataSource,
    rows,
  }
}

module.exports = {
  rowForUser,
}
