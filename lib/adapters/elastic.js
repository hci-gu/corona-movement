const { Client } = require('@elastic/elasticsearch')
const moment = require('moment')
const elastic = new Client({ node: 'http://localhost:9200' })
const weeklyQuery = require('./queries/weekly')
const averageForHourQuery = require('./queries/averageForHour')
const averageSumBucketForHourQuery = require('./queries/averageSumBucketForHour')

const indexExists = async (index) => {
  const res = await elastic.indices.exists({ index })
  return res.body
}

const createIndex = async (index) => {
  if (await indexExists(index)) {
    return
  }
  await elastic.indices.create({ index })
  const res = await elastic.indices.putMapping({
    index,
    body: {
      properties: {
        value: { type: 'integer' },
        date: { type: 'date' },
        date_from: { type: 'date' },
        date_to: { type: 'date' },
        duration: { type: 'integer' },
        data_type: { type: 'text' },
        week: { type: 'integer' },
        time: { type: 'integer' },
        platform_type: { type: 'text' },
      },
    },
  })
  console.log('mapped', res)
}

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

const save = async ({ id, dataPoints, offset }) => {
  console.log(`save ${id}, ${dataPoints.length}, ${offset}`)
  await elastic.bulk({
    index: 'steps',
    body: dataPoints
      .map(transformHealthData)
      .flatMap((doc, index) => [
        { index: { _index: 'steps', _id: `${id}_${offset + index}` } },
        doc,
      ]),
  })
}

const get = async ({
  id,
  from = moment().subtract('3', 'months').format(),
  to = moment().format(),
}) => {
  const res = await elastic.search({
    index: 'steps',
    body: weeklyQuery({ from, to }),
  })

  return res.body
}

const dayFilter = (weekDays = true) => {
  const valToMatch = (val) => ({ match_phrase: { day: val } })

  return {
    bool: {
      should: weekDays
        ? [1, 2, 3, 4, 5].map(valToMatch)
        : [0, 6].map(valToMatch),
      minimum_should_match: 1,
    },
  }
}

const getAverageHour = async ({
  id,
  from = moment().subtract('6', 'months').format(),
  to = moment().format(),
  weekDays = true,
}) => {
  const res = await elastic.search({
    index: 'steps',
    body: averageForHourQuery({ from, to, dayFilter: dayFilter(weekDays) }),
  })

  try {
    return {
      from,
      to,
      result: res.body.aggregations['2'].buckets.map((val) => ({
        value: val['1'].value ? val['1'].value : 0,
        key: val.key,
      })),
    }
  } catch (e) {
    return []
  }
}

const getAverageBucketHour = async ({
  id,
  from = moment().subtract('6', 'months').format(),
  to = moment().format(),
  weekDays = true,
}) => {
  const res = await elastic.search({
    index: 'steps',
    body: averageSumBucketForHourQuery({
      from,
      to,
      dayFilter: dayFilter(weekDays),
    }),
  })

  try {
    return {
      from,
      to,
      result: res.body.aggregations['2'].buckets.map((val) => ({
        value: val['1'].value ? val['1'].value : 0,
        key: val.key,
      })),
    }
  } catch (e) {
    return []
  }
}

module.exports = {
  transformHealthData,
  createIndex,
  save,
  get,
  getAverageHour,
  getAverageBucketHour,
}
