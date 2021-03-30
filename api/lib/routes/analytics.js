const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')

const reqToken = (req, _, next) => {
  const token = req.headers.authorization
  if (token !== process.env.DASHBOARD_AUTH_TOKEN) {
    throw new Error('not authed')
  }
  next()
}

router.get('/totalSteps', reqToken, (_, res) => {
  res.json(db.getTotalSteps())
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

router.post('/analytics', async (req, res) => {
  await db.saveAnalyticsEvent(req.body)

  res.sendStatus(200)
})

module.exports = router
