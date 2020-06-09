require('dotenv').config()

const express = require('express')
const serverless = require('serverless-http')
const bodyParser = require('body-parser')
const fitbit = require('./adapters/fitbit')
const db = require('./adapters/db')
const fs = require('fs')
const cors = require('cors')
const moment = require('moment')

const PORT = process.env.PORT ? process.env.PORT : 4000

if (process.env.NODE_ENV !== 'production') db.createIndex()

const app = express()
app.use(cors())
app.use(bodyParser.json())

app.get('/init', () => db.createIndex())
app.get('/auth', (_, res) => fitbit.redirect(res))
app.get('/callback', (req, res) =>
  fitbit.handleCallback(req).then((token) => res.send({ token }))
)
app.get('/', (req, res) => res.send('hello'))

app.post('/register', async (req, res) => {
  console.log('REGISTER', req.body)
  const user = await db.createUser(req.body)
  console.log('register', user)
  res.send(user)
})
app.post('/health-data', async (req, res) => {
  await db.save(req.body)

  res.send({
    ok: true,
  })
})
app.get('/:id/weeks', async (req, res) => {
  const {
    from = moment().subtract('6', 'months').format(),
    to = moment().format(),
    weekDays = true,
  } = req.query
  const { id } = req.params
  console.log(`GET ${id}, from: ${from}, to: ${to}, weekDays: ${weekDays}`)

  const data = await db.getAverageHour({
    id,
    from,
    to,
    weekDays: weekDays === 'true',
  })

  res.send(data)
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
    to,
  })

  res.send(data)
})
app.post('/ping', async (req, res) => {
  console.log('PING', req.body)
  res.send({ ok: true })
})

if (process.env.NODE_ENV !== 'production')
  app.listen(PORT, () => console.log(`listening on ${PORT}`))

module.exports.handler = serverless(app)
