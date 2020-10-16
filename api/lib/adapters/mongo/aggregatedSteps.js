const moment = require('moment')
const COLLECTION = 'aggregated-steps'
const stepsCollection = require('./steps')
const usersCollection = require('./users')
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

const getInitialDataDate = async (id) => {
  const user = await usersCollection.get(id)

  if (!user) {
    return
  }

  if (!user.initialDataDate) {
    const initalStepData = await stepsCollection.getFirstUpload({ id })
    if (initalStepData) {
      return initalStepData.date
    }
  }

  return user.initialDataDate
}

const getFromToForUser = async (id) => {
  if (id === 'all')
    return {
      from: '2020-01-01',
      to: moment().add(1, 'days').format('YYYY-MM-DD'),
    }
  const initialDate = await getInitialDataDate(id)
  let from = '2020-01-01'
  if (initialDate && moment(initialDate).isAfter(moment(from))) {
    from = moment(initialDate).add(1, 'day').format('YYYY-MM-DD')
  }
  const to = moment().add(1, 'days').format('YYYY-MM-DD')

  return { from, to }
}

const shouldPopulateUntilDate = async (id) => {
  const initalDataDate = await getInitialDataDate(id)
  const user = await usersCollection.get(id)

  if (moment(initalDataDate).isAfter(moment(user.compareDate))) {
    return moment(user.compareDate).subtract(10, 'days')
  }
}

const saveSteps = async (id) => {
  const { from, to } = await getFromToForUser(id)

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
  const { from } = await getFromToForUser(id)
  const data = await stepsCollection.getSummaryForUser({
    id,
    from,
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
  let dataPointsToAdd = []
  if (id !== 'all') {
    const addEmptyToDataToDate = await shouldPopulateUntilDate(id)
    if (addEmptyToDataToDate) {
      const firstDate = doc.data.result[0]
        ? moment(doc.data.result[0].key.substring(0, 10))
        : moment()
      const daysToAdd = firstDate.diff(moment(addEmptyToDataToDate), 'days')
      dataPointsToAdd = Array.from({ length: daysToAdd }).map((_, i) => {
        const key = `${moment(addEmptyToDataToDate)
          .add(i, 'days')
          .format('YYYY-MM-DD')} 00`
        return {
          _id: key,
          value: 0,
          key,
        }
      })
    }
  }

  if (!doc) {
    return {
      result: null,
    }
  }
  doc.data.result = [...dataPointsToAdd, ...doc.data.result]

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
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  saveSteps,
  saveSummary,
  getSteps,
  getSummary,
  shouldPopulateUntilDate,
}
