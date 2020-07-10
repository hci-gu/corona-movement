const elastic = require('./elastic')
const mongo = require('./mongo')
const moment = require('moment')

const transformHealthData = (healthDataPoint) => {
  const duration = Math.round(
    healthDataPoint.date_to - healthDataPoint.date_from
  )
  const date = moment(Math.round(healthDataPoint.date_from + duration / 2))
  const remainder = 10 - (date.minute() % 10)

  const rounded = Math.round(moment(date).minute() / 15) * 15
  const time = moment(date).minute(rounded)

  return {
    value: healthDataPoint.value,
    platform: healthDataPoint.platform,
    date: moment(date).add(remainder, 'minutes').valueOf(),
    duration,
    day: moment(date).day(),
    time: time.hours() * 60 + time.minutes(),
  }
}

const dbAdapter = process.env.DB === 'elastic' ? elastic : mongo

module.exports = {
  ...dbAdapter,
  transformHealthData,
  saveSteps: ({ id, dataPoints }) => {
    dbAdapter.saveSteps(
      dataPoints.map(transformHealthData).map((d) => ({ ...d, id }))
    )
  },
}
