const moment = require('moment')
const COLLECTION = 'aggregated-steps'
const stepsCollection = require('./steps')
const usersCollection = require('./users')
const groupsCollection = require('./groups')
let collection

const getHoursForEveryone = async ({ from, to }) => {
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  const usersSteps = (
    await collection
      .find({
        id: { $ne: 'all' },
        type: 'steps',
      })
      .toArray()
  ).filter((d) => d.data && d.data.result.length > 2000)

  const usersHours = usersSteps.map((doc) => doc.data.result).flat()

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
          value: parseInt(
            data.reduce((sum, d) => sum + d.value, 0) / (data.length || 1)
          ),
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

const sortSteps = (a, b) => {
  if (a.key < b.key) return -1
  if (b.key > a.key) return 1
  return 0
}

const saveSteps = async ({ id, timezone }) => {
  const { from, to } = await getFromToForUser(id)

  let data
  if (id === 'all') {
    data = await getHoursForEveryone({ from, to })
  } else {
    data = await stepsCollection.getHours({
      id,
      from,
      to,
      timezone,
    })
    const days = moment(to).diff(moment(from), 'days')
    const dates = Array.from({ length: days })
      .map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))
      .filter((date) => data.result.every((d) => d.key.indexOf(date) === -1))
      .map((date) => {
        const key = `${date} 00`
        return {
          _id: key,
          value: 0,
          key,
        }
      })
    if (dates.length > 1) {
      data.result = [...data.result, ...dates].sort(sortSteps)
    }
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

  if (!doc) {
    return {
      result: null,
    }
  }

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

  doc.data.result = [...dataPointsToAdd, ...doc.data.result]

  return doc.data
}

const summaryForQuery = async (query) => {
  let before = null,
    after = null
  try {
    const summaries = (await collection.find(query).toArray()).map(
      (d) => d.data
    )
    before =
      summaries.map(({ before }) => before).reduce((sum, x) => sum + x, 0) /
      summaries.length
    after =
      summaries.map(({ after }) => after).reduce((sum, x) => sum + x, 0) /
      summaries.length
  } catch (e) {
    console.log(e)
  }

  return {
    before,
    after,
  }
}

const summaryForGroup = async (groupId) => {
  const group = await groupsCollection.get(groupId)
  const usersInGroup = await usersCollection.usersInGroup(groupId)

  const summary = await summaryForQuery({
    id: { $in: usersInGroup.map((u) => u._id.toString()) },
    type: 'summary',
  })

  return {
    name: group.name,
    data: summary,
  }
}

const getSummary = async ({ id }) => {
  let user
  let userSummary = { before: null, after: null }
  if (id !== 'all') {
    const doc = await collection.findOne({
      id,
      type: 'summary',
    })
    if (doc && doc.data) userSummary = doc.data
    user = await usersCollection.get(id)
  }
  const others = await summaryForQuery({
    id: { $ne: id },
    type: 'summary',
  })

  const summary = {
    user: userSummary,
    others,
  }

  if (user && user.group) {
    const groupSummary = await summaryForGroup(user.group)
    if (groupSummary) {
      summary[groupSummary.name] = groupSummary.data
    }
  }

  return summary
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
