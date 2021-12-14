const moment = require('moment')

const isWeekend = (date) => {
  const day = date.getDay()
  return day === 0 || day === 6
}
const createDateMapBetweenDates = (from, to) => {
  const days = moment(to).diff(from, 'days')
  const map = {}
  Array.from({ length: days }).forEach((_, i) => {
    const date = moment(from).add(i, 'days').format('YYYY-MM-DD')
    map[date] = 0
  })
  return map
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
  isWeekend,
  createDateMapBetweenDates,
  createHourMap,
}
