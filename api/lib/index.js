require('dotenv').config()

const express = require('express')
const serverless = require('serverless-http')
const bodyParser = require('body-parser')
const fitbit = require('./adapters/fitbit')
const db = require('./adapters/db')
const fs = require('fs')
const uuid = require('uuid').v4
const cors = require('cors')
const moment = require('moment')

const PORT = process.env.PORT ? process.env.PORT : 4000

db.createIndex()

const app = express()
app.use(cors())
app.use(bodyParser.json())

app.get('/auth', (_, res) => fitbit.redirect(res))
app.get('/callback', (req, res) =>
  fitbit.handleCallback(req).then((token) => res.send({ token }))
)
app.get('/', (req, res) => res.send('hello'))

app.get('/register', async (req, res) => {
  const id = uuid()
  console.log('register', id)
  res.send({
    id,
  })
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
app.post('/ping', async (req, res) => {
  console.log('PING', req.body)
  res.send({ ok: true })
})

app.listen(PORT, () => console.log(`listening on ${PORT}`))

module.exports.handler = serverless(app)
