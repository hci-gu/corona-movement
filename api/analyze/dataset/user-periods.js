const { translateGender, translateAgeRange } = require('../utils')
const {
  compareDateForUser,
  periodsForUser,
  averageDayForForPeriod,
} = require('./utils')

let localDB
const init = (db) => {
  localDB = db
}

const periods = (user, hours, compareDate, length = 3) => {
  const list = periodsForUser(compareDate, length)

  return list.map((period) => {
    let rows = []
    try {
      rows = averageDayForForPeriod(hours, period)
    } catch (e) {}
    return rows
  })
}

const rowForUser = (user, steps) => {
  const userId = user._id.toString()
  const hours = steps.map(({ key, value }) => {
    const [date, hour] = key.split(' ')
    return { date, hour, value }
  })

  if (!hours.length) {
    throw new Error('User has no data')
  }

  const compareDate = compareDateForUser(user)
  let rows = []
  periods(user, hours, compareDate, 24).forEach((period) => {
    rows = [...rows, ...period]
  })

  return {
    id: userId,
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
