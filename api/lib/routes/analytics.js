const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')
const userUtils = require('../../analyze/user-utils')

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

let userCache
router.get('/users', reqToken, async (_, res) => {
  let timer = new Date()
  if (userCache) return res.send(userCache)
  const database = await db.getDB()
  userUtils.init(database)
  const users = await userUtils.getUsers()
  userCache = users
  console.log('respond', new Date() - timer)
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

router.post('/analytics', async (req, res) => {
  await db.saveAnalyticsEvent(req.body)

  res.sendStatus(200)
})

module.exports = router
