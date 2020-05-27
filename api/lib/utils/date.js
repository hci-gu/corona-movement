const moment = require('moment')

const moveDay = (date) =>
  date.day() === 6 ? date.day(8) : date.day() === 0 ? date.day(-2) : null

const getDaysDiffFromWeeks = (from, to) => {
  let fromWeek = from.week()
  let toWeek = to.week()
  let adjust = 1

  if (fromWeek !== toWeek) {
    if (toWeek < fromWeek) {
      toWeek += fromWeek
    }
    adjust += -2 * (toWeek - fromWeek)
  }
  return adjust
}

const getBusinessDaysBetween = (fromDateString, toDateString) => {
  let from = moment(fromDateString).startOf('day')
  let to = moment(toDateString).startOf('day')

  if (
    to.isBefore(from) ||
    (from.dayOfYear() === to.dayOfYear() && from.year() === to.year())
  ) {
    return 0
  }

  moveDay(from)
  moveDay(to)

  return to.diff(from, 'days') + getDaysDiffFromWeeks(from, to)
}

module.exports = {
  getBusinessDaysBetween,
}
