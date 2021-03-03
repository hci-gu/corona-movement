const express = require('express')
const router = express.Router()
const db = require('../adapters/db')

router.post('/register', async (req, res) => {
  console.log('POST /register', req.body)
  const { _id } = await db.createUser({
    ...req.body,
    appName: req.headers['app-name'],
  })
  const user = await db.getUser(_id.toString())
  res.send(user)
})
router.delete('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('DELETE /user/', id)
  const result = await db.removeUser(id)
  if (result) {
    await db.removeStepsForUser(id)
    await db.removeAnalyticsForUser(id)
    return res.sendStatus(200)
  }
  res.sendStatus(404)
})
router.get('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('GET /user/', id)
  const user = await db.getUser(id)
  res.send(user)
})
router.patch('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('PATCH /user/', id, req.body)
  if (!req.body.compareDate && !req.body.afterPeriods) {
    const user = await db.updateUser({ id, update: req.body })
    return res.send(user)
  }
  const user = await db.updateUser({
    id,
    update: req.body,
  })
  await Promise.all([
    db.saveAggregatedSteps({
      id,
      timezone: req.body.timezone ? req.body.timezone : undefined,
    }),
    db.saveAggregatedSummary(id),
  ])
  res.send(user)
})

module.exports = router
