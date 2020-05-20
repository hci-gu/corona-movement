const elastic = require('./elastic')
const mongo = require('./mongo')
const moment = require('moment')

const transformHealthData = (healthDataPoint) => {
  const duration = Math.round(
    healthDataPoint.date_to - healthDataPoint.date_from
  )
  const date = Math.round(healthDataPoint.date_from + duration / 2)
  const rounded = Math.round(moment(date).minute() / 15) * 15
  const time = moment(date).minute(rounded)

  return {
    ...healthDataPoint,
    date,
    duration,
    day: moment(date).day(),
    time: time.hours() * 60 + time.minutes(),
  }
}

const dbAdapter = process.env.DB === 'elastic' ? elastic : mongo

module.exports = {
  ...dbAdapter,
  save: ({ id, dataPoints, offset }) => {
    dbAdapter.save({
      id,
      dataPoints: dataPoints
        .map(transformHealthData)
        .map((d) => ({ ...d, id })),
      offset,
    })
  },
}
