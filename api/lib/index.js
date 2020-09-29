require('dotenv').config()

const express = require('express')
const serverless = require('serverless-http')
const bodyParser = require('body-parser')
const db = require('./adapters/db')
const { uploadFeedback } = require('./adapters/mongo/feedback')
const cors = require('cors')
const moment = require('moment')

const PORT = process.env.PORT ? process.env.PORT : 4000

const app = express()
app.use(cors())
app.use(bodyParser.json({ limit: '25mb' }))
app.use(async (_, __, next) => {
  await db.inited()
  next()
})

app.get('/fitbit/callback', (_, res) => res.redirect('wfhmovement:/'))
app.get('/', (_, res) => res.send('hello'))

app.post('/register', async (req, res) => {
  console.log('POST /register', req.body)
  const user = await db.createUser(req.body)
  console.log('register', user)
  res.send(user)
})
app.delete('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('DELETE /user/', id)
  const result = await db.removeUser(id)
  if (result) {
    await db.removeStepsForUser(id)
    return res.sendStatus(200)
  }
  res.sendStatus(404)
})
app.get('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('GET /user/', id)
  const user = await db.getUser(id)
  res.send(user)
})
app.patch('/user/:id', async (req, res) => {
  const { id } = req.params
  console.log('PATCH /user/', id, req.body)
  const user = await db.updateUser({ id, update: req.body })
  res.send(user)
})
app.post('/health-data', async (req, res) => {
  const { id, dataPoints, createAggregation } = req.body

  await db.saveSteps({ id, dataPoints })

  if (createAggregation) {
    await Promise.all([
      db.saveAggregatedSteps(id),
      db.saveAggregatedSummary(id),
    ])
  }

  res.send({
    ok: true,
  })
})
app.get('/:id/update', async (req, res) => {
  const { id } = req.params
  await db.saveAggregatedSteps(id)
  await db.saveAggregatedSummary(id)
  res.send({ ok: true })
})

app.get('/:id/hours', async (req, res) => {
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
app.get('/:id/summary', async (req, res) => {
  const { id } = req.params
  console.log('GET summary', id)

  const data = await db.getSummary({ id })

  res.send(data)
})
app.get('/:id/last-upload', async (req, res) => {
  const { id } = req.params
  console.log('GET last-upload', id)

  const data = await db.getLastUpload({ id })

  res.send(data)
})

app.get('/should-unlock', async (_, res) => res.send(true))

app.post('/unlock', async (req, res) => {
  const { code } = req.body

  const exists = await db.codeExists(code)

  res.sendStatus(exists ? 200 : 401)
})

app.post('/feedback', async (req, res) => {
  const uploadImageUrl = await uploadFeedback(req.body)
  res.send({
    uploadImageUrl,
  })
})

app.post('/ping', async (req, res) => {
  console.log('PING', req.body)
  res.send({ ok: true })
})

if (process.env.NODE_ENV !== 'production')
  app.listen(PORT, () => console.log(`listening on ${PORT}`))

module.exports.handler = serverless(app)
module.exports.app = app
