const moment = require('moment')
const COLLECTION = 'aggregated-steps'
const stepsCollection = require('./steps')
const usersCollection = require('./users')
const groupsCollection = require('./groups')
const { FROM_DATE } = require('../../constants')
let collection

const getHoursForEveryone = async ({ from, to }) => {
  const dates = Array.from({
    length: moment(to).diff(from, 'days'),
  }).map((_, i) => moment(from).add(i, 'days').format('YYYY-MM-DD'))

  const usersSteps = (
    await collection
      .aggregate([
        {
          $match: {
            id: { $ne: 'all' },
            type: 'steps',
          },
        },
      ])
      .toArray()
  ).filter((d) => d.data && d.data.result.length > 2000)

  const usersHours = usersSteps.reduce((acc, doc) => {
    doc.data.result.forEach((res) => {
      const key = res.key
      if (!acc[key]) {
        acc[key] = [res.value]
      } else {
        acc[key] = [...acc[key], res.value]
      }
    })
    return acc
  }, {})

  const result = dates
    .map((date) =>
      Array.from({
        length: 24,
      }).map((_, hour) => {
        const pad = (hour) => (hour < 10 ? `0${hour}` : `${hour}`)
        const key = `${date} ${pad(hour)}`
        const data = usersHours[key] ? usersHours[key] : []
        return {
          key,
          value: parseInt(
            data.reduce((sum, val) => sum + val, 0) / (data.length || 1)
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

const getFromToForUser = async (id, onlyFullDays = false) => {
  if (id === 'all')
    return {
      from: FROM_DATE,
      to: moment().add(1, 'days').format('YYYY-MM-DD'),
    }

  const user = await usersCollection.get(id)

  if (!user) {
    return
  }

  const [initalStepData, lastStepData] = await Promise.all([
    stepsCollection.getFirstUpload({ id }),
    stepsCollection.getLastUpload({ id }),
  ])

  if (!initalStepData || !lastStepData) {
    throw new Error('user has no stepdata')
  }

  return {
    from: moment(initalStepData.date).add(1, 'day').format('YYYY-MM-DD'),
    to: onlyFullDays
      ? moment(lastStepData.date).subtract(1, 'day').format('YYYY-MM-DD')
      : moment(lastStepData.date).add(1, 'day').format('YYYY-MM-DD'),
  }
}

const sortSteps = (a, b) => {
  if (a.key < b.key) return -1
  if (b.key > a.key) return 1
  return 0
}

const saveSteps = async ({ id, timezone }) => {
  try {
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
      if (dates.length > 0) {
        data.result = [...data.result, ...dates].sort(sortSteps)
      }
    }

    await save({ id, type: 'steps', data })
  } catch (e) {
    console.log(e)
  }
}

const saveDays = async ({ id }) => {
  try {
    const data = await stepsCollection.getDaysForUser({ id })

    await save({ id, type: 'days', data })
  } catch (e) {
    console.log(e)
  }
  return getDays({ id })
}

const saveSummary = async (id) => {
  if (id === 'all') return
  try {
    const { from, to } = await getFromToForUser(id, true)
    const data = await stepsCollection.getSummaryForUser({
      id,
      from,
      to,
    })

    await save({ id, type: 'summary', data })
  } catch (e) {
    console.log(e)
  }
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

const getDays = async ({ id }) => {
  const doc = await collection.findOne({
    id,
    type: 'days',
  })

  if (!doc) {
    return {
      result: null,
    }
  }

  return doc.data
}

const summaryForQuery = async (query) => {
  try {
    const result = await collection
      .aggregate([
        {
          $match: {
            ...query,
            'data.before': { $ne: NaN },
            'data.after': { $ne: NaN },
          },
        },
        {
          $group: {
            _id: 'id',
            before: { $avg: '$data.before' },
            after: { $avg: '$data.after' },
          },
        },
      ])
      .toArray()

    if (result.length) {
      return {
        before: result[0].before,
        after: result[0].after,
      }
    }
  } catch (e) {
    console.log(e)
  }

  return {
    before: null,
    after: null,
  }
}

const summaryForGroup = async (groupId) => {
  const group = await groupsCollection.get(groupId)
  const usersInGroup = await usersCollection.usersInGroup(groupId)

  let summary
  if (usersInGroup.length > 4) {
    summary = await summaryForQuery({
      id: { $in: usersInGroup.map((u) => u._id.toString()) },
      type: 'summary',
    })
  } else {
    summary = {
      before: null,
      after: null,
    }
  }

  return {
    name: group ? group.name : 'group error',
    data: summary,
  }
}

const applyGroupToSummary = async (groupId, summary) => {
  const groupSummary = await summaryForGroup(groupId)
  if (groupSummary) {
    summary[groupSummary.name] = groupSummary.data
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

  if (user && user.groups) {
    await Promise.all(
      user.groups.map((groupId) => applyGroupToSummary(groupId, summary))
    )
  } else if (user && user.group) {
    await applyGroupToSummary(user.group, summary)
  }

  return summary
}

const getAllSummariesMap = async () => {
  const docs = await collection.find({ type: 'summary' }).toArray()
  return docs.reduce((acc, curr) => {
    acc[curr.id] = {
      user: curr.data,
    }
    return acc
  }, {})
}
const getAllDaysMap = async () => {
  const docs = await collection.find({ type: 'days' }).toArray()
  return docs.reduce((acc, curr) => {
    acc[curr.id] = curr.data
    return acc
  }, {})
}

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  saveSteps,
  saveDays,
  saveSummary,
  getSteps,
  getDays,
  getSummary,
  getAllSummariesMap,
  getAllDaysMap,
}
