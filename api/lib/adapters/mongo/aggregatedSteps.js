const moment = require('moment')
const COLLECTION = 'aggregated-steps'
const stepsCollection = require('./steps')
let collection

const getHoursForEveryone = async ({ from, to }) => {
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  const usersHours = (
    await collection
      .find({
        id: { $ne: 'all' },
        type: 'steps',
      })
      .toArray()
  )
    .map((doc) => doc.data.result)
    .flat()

  const result = dates
    .map((date) =>
      Array.from({
        length: 24,
      }).map((_, hour) => {
        const pad = (hour) => (hour < 10 ? `0${hour}` : `${hour}`)
        const key = `${date} ${pad(hour)}`
        const data = usersHours.filter((date) => date.key === key)
        return {
          key,
          value: data.reduce((sum, d) => sum + d.value, 0) / (data.length || 1),
        }
      })
    )
    .flat()

  return {
    result,
    from,
    to,
  }
}

const saveSteps = async (id) => {
  const from = '2020-01-01'
  const to = moment().format('YYYY-MM-DD')

  let data
  if (id === 'all') {
    data = await getHoursForEveryone({ from, to })
  } else {
    data = await stepsCollection.getHours({
      id,
      from,
      to,
    })
  }

  await save({ id, type: 'steps', data })
}

const saveSummary = async (id) => {
  if (id === 'all') return
  const data = await stepsCollection.getSummaryForUser({
    id,
    from: '2020-01-01',
  })

  await save({ id, type: 'summary', data })
}

const save = ({ id, type, data }) =>
  collection.updateOne(
    { id, type },
    {
      $set: {
        id,
        type,
        data,
      },
    },
    { upsert: true }
  )

const getSteps = async ({ id }) => {
  const doc = await collection.findOne({
    id,
    type: 'steps',
  })

  if (!doc) {
    return {
      result: null,
    }
  }

  return doc.data
}

const getSummary = async ({ id }) => {
  let user = { before: null, after: null }
  if (id !== 'all') {
    const doc = await collection.findOne({
      id,
      type: 'summary',
    })
    if (doc && doc.data) user = doc.data
  }

  let others = { before: null, after: null }
  try {
    const othersSummaries = (
      await collection
        .find({
          id: { $ne: id },
          type: 'summary',
        })
        .toArray()
    ).map((d) => d.data)
    others = {
      before:
        othersSummaries
          .map(({ before }) => before)
          .reduce((sum, x) => sum + x, 0) / othersSummaries.length,
      after:
        othersSummaries
          .map(({ after }) => after)
          .reduce((sum, x) => sum + x, 0) / othersSummaries.length,
    }
  } catch (e) {
    console.log(e)
  }

  return {
    user,
    others,
  }
}

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  saveSteps,
  saveSummary,
  getSteps,
  getSummary,
}
