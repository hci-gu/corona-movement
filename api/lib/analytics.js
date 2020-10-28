const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('./adapters/db')

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
  res.json(users.filter((u) => u.created).map(({ created }) => created))
})

router.get('/dashboard', async (_, res) => {
  const today = moment().startOf('day').toDate()
  const oneWeekAgo = moment().subtract(7, 'days').startOf('day').toDate()

  res.send({
    users: await db.userCount({}),
    usersToday: await db.userCount({ from: today }),
    usersLastSevenDays: await db.userCount({ from: oneWeekAgo }),
    sessions: await db.analyticsCount({ event: 'openApp' }),
    sessionsToday: await db.analyticsCount({
      event: 'openApp',
      from: today,
    }),
    sessionsLastSevenDays: await db.analyticsCount({
      event: 'openApp',
      from: oneWeekAgo,
    }),
  })
})

module.exports = router
