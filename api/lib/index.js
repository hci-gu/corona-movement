require('dotenv').config()

const express = require('express')
const serverless = require('serverless-http')
const bodyParser = require('body-parser')
const querystring = require('querystring')
const db = require('./adapters/db')
const { uploadFeedback } = require('./adapters/mongo/feedback')
const cors = require('cors')

const analyticsRoutes = require('./routes/analytics')
const stepsRoutes = require('./routes/steps')
const usersRoutes = require('./routes/users')
const groupsRoutes = require('./routes/groups')

const PORT = process.env.PORT ? process.env.PORT : 4000

const app = express()
app.use(cors())
app.use(bodyParser.json({ limit: '25mb' }))
app.use(async (_, __, next) => {
  await db.inited()
  next()
})

app.use('/analytics', analyticsRoutes)
app.use('/groups', groupsRoutes)
app.use(stepsRoutes)
app.use(usersRoutes)

app.get('/', (_, res) => res.send('hello'))
app.get('/fitbit/callback', (_, res) => res.redirect('wfhmovement:/'))

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
app.get('/deeplink', async (req, res) =>
  res.redirect(`wfhmovement://localhost?${querystring.encode(req.query)}`)
)
app.get('/events', async (req, res) => {
  const { language } = req.headers
  if (language === 'sv') {
    return res.send([
      {
        date: '2020-03-16',
        text: 'Rekommendationer att jobba hemifrån.',
      },
    ])
  }
  res.send([
    {
      date: '2020-03-16',
      text: 'Swedish recommendations to work from home.',
    },
  ])
})

if (process.env.NODE_ENV !== 'production')
  app.listen(PORT, () => console.log(`listening on ${PORT}`))

module.exports.handler = serverless(app)
module.exports.app = app
