require('dotenv').config()

const express = require('express')
const bodyParser = require('body-parser')
const fitbit = require('./adapters/fitbit')
const elastic = require('./adapters/elastic')
const fs = require('fs')
const uuid = require('uuid').v4
const cors = require('cors')

const PORT = process.env.PORT ? process.env.PORT : 4000

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
  fs.writeFileSync('./data.json', JSON.stringify(req.body, null, 2))
  await elastic.save(req.body)

  res.send({
    ok: true,
  })
})
app.get('/:id/health-data', async (req, res) => {
  const { from, to } = req.query
  const { id } = req.params
  console.log(`GET ${id}, from: ${from}, to: ${to}`)
  const data = await elastic.get({})
  res.send(data)
})
app.get('/:id/weeks', async (req, res) => {
  const { from, to, weekDays } = req.query
  const { id } = req.params
  console.log(`GET ${id}, from: ${from}, to: ${to}, weekDays: ${weekDays}`)
  const data = await elastic.getAverageHour({
    from,
    to,
    weekDays: weekDays === 'true',
  })
  res.send(data)
})
app.get('/:id/weeks_bucket', async (req, res) => {
  const { from, to, weekDays } = req.query
  const { id } = req.params
  console.log(`GET BKT ${id}, from: ${from}, to: ${to}, weekDays: ${weekDays}`)
  const data = await elastic.getAverageBucketHour({
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

elastic.createIndex('steps')
