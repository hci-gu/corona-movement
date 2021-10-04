const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')
const userUtils = require('../../analyze/user-utils')
const mongo = require('../adapters/mongo')
const dataset = require('../../analyze/dataset')

const reqToken = (req, _, next) => {
  const token = req.headers.authorization
  if (token !== process.env.DASHBOARD_AUTH_TOKEN) {
    throw new Error('not authed')
  }
  next()
}

router.get('/totalSteps', reqToken, async (_, res) => {
  const response = await db.getTotalSteps()
  res.json(response)
})

router.get('/userRegistrations', reqToken, async (_, res) => {
  const users = await db.getAllUsers()
  res.json(
    users
      .filter((u) => u.created)
      .map((u) => ({
        app: u.appName ? u.appName : 'WFH Movement',
        date: u.created,
      }))
  )
})

const getUsersNumbersForApp = async (app) => {
  const today = moment().startOf('day').toDate()
  const oneWeekAgo = moment().subtract(7, 'days').startOf('day').toDate()

  return {
    users: await db.userCount({ params: app }),
    usersToday: await db.userCount({ from: today, params: app }),
    usersLastSevenDays: await db.userCount({ from: oneWeekAgo, params: app }),
  }
}

router.get('/dashboard', reqToken, async (_, res) => {
  const apps = [
    null,
    {
      $or: [
        { appName: { $eq: 'WFH Movement' } },
        { appName: { $exists: false } },
      ],
    },
    { appName: 'SFH Movement' },
  ]
  const [all, wfh, sfh] = await Promise.all(apps.map(getUsersNumbersForApp))

  res.send({
    ...all,
    'WFH Movement': {
      ...wfh,
    },
    'SFH Movement': {
      ...sfh,
    },
  })
})

router.get('/users', async (req, res) => {
  const { limit, offset } = req.query
  const users = await mongo.getAggregatedUsers({
    offset: offset ? parseInt(offset) : undefined,
    limit: limit ? parseInt(limit) : undefined,
  })
  res.send(users)
})

router.get('/save-users', async (req, res) => {
  const { offset, limit } = req.query
  const database = await db.getDB()
  userUtils.init(database)

  await userUtils.saveUsers(
    offset ? parseInt(offset) : undefined,
    limit ? parseInt(limit) : undefined
  )
  res.send('DONE')
})

router.get('/clear-users', async (req, res) => {
  await mongo.clearAggregatedUsers()
  res.send('DONE')
})

router.post('/dataset/:id', async (req, res) => {
  const { id } = req.params

  const database = await db.getDB()
  dataset.init(database)

  try {
    await mongo.createDataset(id)
    res.send(id)
  } catch (e) {
    res.statusCode = 400
    res.send({ error: e.message })
  }
})

router.post('/dataset/:id/rows', async (req, res) => {
  const { id } = req.params
  const { offset, limit } = req.query

  const database = await db.getDB()
  dataset.init(database)
  const rows = await dataset.createRows(parseInt(offset), parseInt(limit))

  if (!rows.length) {
    res.statusCode = 404
    return res.send({ error: 'No users found' })
  }

  try {
    await mongo.fillDataset(id, rows)
    res.send(id)
  } catch (e) {
    res.statusCode = 400
    res.send({ error: e.message })
  }
})

router.get('/dataset/:id', async (req, res) => {
  const { id } = req.params
  const { offset, limit } = req.query

  const data = await mongo.getDataset(id, parseInt(offset), parseInt(limit))

  res.send(data)
})

router.get('/dataset', async (_, res) => {
  const data = await mongo.listDatasets()

  res.send(data)
})

router.delete('/dataset/:id', async (req, res) => {
  const { id } = req.params

  const data = await mongo.removeDataset(id)

  res.send(data)
})

const getAnalyticsForUser = async (user) => {
  const analyticsInfo = await db.getEventsForUser(user._id.toString())

  return {
    id: user._id,
    created: user.created,
    events: analyticsInfo,
  }
}

router.get('/usage-analytics', async (req, res) => {
  const users = await db.getAllUsers()

  const usersWithEvents = await Promise.all(users.map(getAnalyticsForUser))

  res.send(usersWithEvents.filter((u) => !!u.events))
})

router.post('/', async (req, res) => {
  await db.saveAnalyticsEvent(req.body)

  res.sendStatus(200)
})

module.exports = router
