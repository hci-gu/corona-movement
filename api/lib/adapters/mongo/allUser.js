const moment = require('moment')
const usersCollection = require('./users')
const stepsCollection = require('./steps')
const { getUserPeriods } = require('./steps/utils')
const aggregatedSteps = require('./aggregatedSteps')
const COLLECTION = 'allUser'
let collection

const mapUser = async (u) => {
  const id = u._id.toString()
  const stepDataPoints = await stepsCollection.stepDataPointCountForUser({
    id,
  })
  const summary = await aggregatedSteps.getSummary({ id })
  const { before, after } = summary.user

  u.stepDataPoints = stepDataPoints
  u.stepsBefore = before
  u.stepsAfter = after
  return u
}

const filterUsers = (users) => {
  return users.filter(
    (u) => u.stepsBefore > 0 && u.stepsAfter > 0 && u.stepDataPoints > 2500
  )
}

const getAllValidUsers = async () => {
  const allUsers = await usersCollection.getAllExcept()
  const mappedUsers = await Promise.all(allUsers.map(mapUser))
  return filterUsers(mappedUsers)
}

const saveSummary = async (users) => {
  const totalBefore = users.reduce((acc, curr) => {
    return acc + curr.stepsBefore
  }, 0)
  const totalAfter = users.reduce((acc, curr) => {
    return acc + curr.stepsAfter
  }, 0)

  const type = 'summary'
  await collection.updateOne(
    { type },
    {
      $set: {
        type,
        data: {
          before: Math.round(totalBefore / users.length),
          after: Math.round(totalAfter / users.length),
        },
      },
    },
    { upsert: true }
  )
}

const getUserDay = async (user) => {
  const id = user._id.toString()
  const latestDataDate = await stepsCollection.getLastUpload({
    id,
  })
  const [beforePeriods, afterPeriods] = getUserPeriods(
    user,
    latestDataDate ? latestDataDate.date : null
  )

  const [before, after] = await Promise.all([
    stepsCollection.getAverageHoursForUserPeriods({
      id,
      periods: beforePeriods,
    }),
    stepsCollection.getAverageHoursForUserPeriods({
      id,
      periods: afterPeriods,
    }),
  ])

  return [before, after]
}

const getUserDays = async (user) => {
  const id = user._id.toString()
  const days = await stepsCollection.getDailySteps(id)

  return days
}

const saveDays = async (users) => {
  const allUserDays = await Promise.all(users.map((u) => getUserDays(u)))

  const days = Array.from({
    length: moment().diff(moment('2020-01-01'), 'days'),
  }).map((_, i) => i)
  const dayMap = days.reduce((acc, curr) => {
    const key = moment('2020-01-01').add(curr, 'days').format('YYYY-MM-DD')
    acc[key] = {
      value: 0,
      users: 0,
    }
    return acc
  }, {})
  console.log(dayMap)

  allUserDays.forEach((dayArray) => {
    dayArray.forEach((day) => {
      if (!dayMap[day._id]) return
      dayMap[day._id] = {
        value: dayMap[day._id].value + day.value,
        users: dayMap[day._id].users + 1,
      }
    })
  })

  const type = 'days'
  await collection.updateOne(
    { type },
    {
      $set: {
        type,
        data: Object.keys(dayMap).map((date) => ({
          date,
          value: dayMap[date].value / dayMap[date].users + 0.0000001,
        })),
      },
    },
    { upsert: true }
  )
}

const getDays = async () => {
  const response = await collection.findOne({ type: 'days' })
  if (response) {
    return response.data
  }
  return []
}

const saveHours = async (users) => {
  const days = await Promise.all(users.map((u) => getUserDay(u)))

  const hours = Array.from({ length: 24 }).map((_, i) => i)
  const dayMap = hours.reduce((acc, curr) => {
    acc[curr] = 0
    return acc
  }, {})

  const day = {
    before: { ...dayMap },
    after: { ...dayMap },
  }

  days.forEach(([before, after]) => {
    before.forEach(({ hour, value }) => {
      if (value && isFinite(value)) {
        day.before[hour] = day.before[hour] + value
      }
    })
    after.forEach(({ hour, value }) => {
      if (value && isFinite(value)) {
        day.after[hour] = day.after[hour] + value
      }
    })
  })

  const type = 'average-hours'
  await collection.updateOne(
    { type },
    {
      $set: {
        type,
        data: {
          before: Object.keys(dayMap).map((key) => ({
            key: parseInt(key),
            value: day.before[key] / users.length,
          })),
          after: Object.keys(dayMap).map((key) => ({
            key: parseInt(key),
            value: day.after[key] / users.length,
          })),
        },
      },
    },
    { upsert: true }
  )
}

const getHours = async () => {
  const response = await collection.findOne({ type: 'average-hours' })
  if (response) {
    return response.data
  }
  return []
}

const getSummary = async () => {
  const response = await collection.findOne({ type: 'summary' })
  if (response) {
    return response.data
  }
  return {}
}

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  getDays,
  getHours,
  getSummary,
  save: async () => {
    const users = await getAllValidUsers()
    await Promise.all([saveDays(users), saveHours(users), saveSummary(users)])
  },
}
