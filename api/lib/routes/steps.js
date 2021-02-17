const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')

router.post('/health-data', async (req, res) => {
  const { id, dataPoints, createAggregation, timezone } = req.body

  await db.saveSteps({ id, dataPoints })

  if (createAggregation) {
    await Promise.all([
      db.saveAggregatedSteps({ id, timezone }),
      db.saveAggregatedSummary(id),
    ])
  }

  res.send({
    ok: true,
  })
})

router.get('/:id/hours', async (req, res) => {
  const {
    from = moment().subtract('6', 'months').format(),
    to = moment().format(),
  } = req.query
  const { id } = req.params
  console.log(`GET hours ${id}, from: ${from}, to: ${to}`)

  const data = await db.getHours({
    id,
    from,
    to: moment(to).add(1, 'day').format(),
  })

  res.send(data)
})
router.get('/:id/summary', async (req, res) => {
  const { id } = req.params
  console.log('GET summary', id)

  const data = await db.getSummary({ id })

  res.send(data)
})
router.get('/:id/last-upload', async (req, res) => {
  const { id } = req.params
  console.log('GET last-upload', id)

  const data = await db.getLastUpload({ id })

  res.send(data)
})
router.get('/:id/update', async (req, res) => {
  const { id } = req.params
  const { timezone } = req.query
  let time = new Date()
  await Promise.all([
    db.saveAggregatedSteps({ id, timezone }),
    db.saveAggregatedSummary(id),
  ])
  res.send({ ok: true, time: new Date() - time })
})

module.exports = router
