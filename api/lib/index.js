require('dotenv').config()

const express = require('express')
const serverless = require('serverless-http')
const bodyParser = require('body-parser')
const db = require('./adapters/db')
const { uploadFeedback } = require('./adapters/mongo/feedback')
const cors = require('cors')
const moment = require('moment')
const analyticsRoutes = require('./analytics')

const PORT = process.env.PORT ? process.env.PORT : 4000

const wait = (time) =>
  new Promise((resolve) => {
    setTimeout(() => resolve(), time)
  })

const app = express()
app.use(cors())
app.use(bodyParser.json({ limit: '25mb' }))
app.use(async (_, __, next) => {
  await db.inited()
  next()
})

app.use('/analytics', analyticsRoutes)

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
    await db.removeAnalyticsForUser(id)
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
  if (!req.body.compareDate) {
    const user = await db.updateUser({ id, update: req.body })
    res.send(user)
    return
  }
  const user = await db.updateUser({
    id,
    update: { compareDate: req.body.compareDate },
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
app.post('/health-data', async (req, res) => {
  const { id, dataPoints, createAggregation, timezone } = req.body

  await db.saveSteps({ id, dataPoints })

  if (createAggregation) {
    await wait(1000)
    await Promise.all([
      db.saveAggregatedSteps({ id, timezone }),
      db.saveAggregatedSummary(id),
    ])
  }

  res.send({
    ok: true,
  })
})
app.get('/:id/update', async (req, res) => {
  const { id } = req.params
  const { timezone } = req.query
  let time = new Date()
  await Promise.all([
    db.saveAggregatedSteps({ id, timezone }),
    db.saveAggregatedSummary(id),
  ])
  res.send({ ok: true, time: new Date() - time })
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

app.get('/should-unlock', async (_, res) => {
  db.saveAnalyticsEvent({
    event: 'openApp',
  })
  res.send(false)
})

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

app.post('/analytics', async (req, res) => {
  await db.saveAnalyticsEvent(req.body)

  res.sendStatus(200)
})

app.post('/ping', async (_, res) => res.send({ ok: true }))

app.get('/total', async (_, res) => {
  const result = await db.getTotalSteps()
  res.send(result)
})

const promiseSeries = (items, method) => {
  const results = []

  function runMethod(item) {
    return new Promise((resolve, reject) => {
      method(item)
        .then((res) => {
          results.push(res)
          resolve(res)
        })
        .catch((err) => reject(err))
    })
  }

  return items
    .reduce(
      (promise, item) => promise.then(() => runMethod(item)),
      Promise.resolve()
    )
    .then(() => results)
}

app.get('/update-everyone', async (req, res) => {
  let time = new Date()
  const users = await db.getAllUsers()

  await promiseSeries(users, async (u) => {
    await db.saveAggregatedSteps(u._id.toString())
    await db.saveAggregatedSummary(u._id.toString())
  })
  res.send({ ok: true, time: new Date() - time })
})

if (process.env.NODE_ENV !== 'production')
  app.listen(PORT, () => console.log(`listening on ${PORT}`))

module.exports.handler = serverless(app)
module.exports.app = app
