const { Client } = require('@elastic/elasticsearch')
const moment = require('moment')
const elastic = new Client({ node: 'http://localhost:9200' })
const weeklyQuery = require('./queries/weekly')
const averageForHourQuery = require('./queries/averageForHour')
const averageSumBucketForHourQuery = require('./queries/averageSumBucketForHour')

const INDEX_NAME = 'steps'

const indexExists = async () => {
  const res = await elastic.indices.exists({ index: INDEX_NAME })
  return res.body
}

const createIndex = async () => {
  if (await indexExists()) {
    return
  }
  await elastic.indices.create({ index: INDEX_NAME })
  const res = await elastic.indices.putMapping({
    index: INDEX_NAME,
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
}

const save = async ({ id, dataPoints }) => {
  await elastic.bulk({
    index: INDEX_NAME,
    body: dataPoints.flatMap((doc) => [
      { index: { _index: INDEX_NAME, _id: `${id}_${doc.date}` } },
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
    index: INDEX_NAME,
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

const getAverageHour = async ({ id, from, to, weekDays }) => {
  const res = await elastic.search({
    index: INDEX_NAME,
    body: averageSumBucketForHourQuery({
      id,
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
        key: val.key / 60,
      })),
    }
  } catch (e) {
    return []
  }
}

module.exports = {
  createIndex,
  save,
  get,
  getAverageHour,
}
