const moment = require('moment')
const usersCollection = require('../users')
const { BEFORE_END_DATE } = require('../../../constants')

const queryForPeriods = ({ id, periods, weekDays }) => {
  const query = {
    $or: periods.map(({ from, to }) => ({
      date: {
        $gte: new Date(from),
        $lt: new Date(to),
      },
    })),
  }
  if (weekDays !== undefined) {
    query['day'] = { $in: weekDays ? [1, 2, 3, 4, 5] : [0, 6] }
  }
  if (id !== 'all') {
    query['id'] = id
  }

  return query
}

const daysInPeriods = (periods) => {
  return periods.reduce((total, period) => {
    const days = moment(period.to).diff(moment(period.from), 'days')
    return total + days
  }, 0)
}

const getUserPeriods = (user, latestDataDate) => {
  const beforePeriods = usersCollection.beforePeriodsForUser(user)

  if (user.afterPeriods) {
    return [
      beforePeriods,
      user.afterPeriods.map((p) => ({
        from: p.from,
        to: p.to ? p.to : latestDataDate,
      })),
    ]
  }

  const afterPeriods = [
    {
      from: user.compareDate ? user.compareDate : BEFORE_END_DATE,
      to: latestDataDate,
    },
  ]

  return [beforePeriods, afterPeriods]
}

module.exports = {
  queryForPeriods,
  daysInPeriods,
  getUserPeriods,
}
