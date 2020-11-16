const { MongoClient } = require('mongodb')
const request = require('supertest')
const moment = require('moment')

let db
const STEPS_COLLECTION = 'steps'
const USERS_COLLECTION = 'users'
const CODES_COLLECTION = 'codes'
const AGGREGATED_STEPS_COLLECTION = 'aggregated-steps'

const cleanup = async () => {
  await Promise.all([
    db.collection(USERS_COLLECTION).deleteMany({}),
    db.collection(STEPS_COLLECTION).deleteMany({}),
    db.collection(CODES_COLLECTION).deleteMany({}),
    db.collection(AGGREGATED_STEPS_COLLECTION).deleteMany({}),
  ])
}

const init = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO)
  db = client.db(process.env.DB_NAME)
  await db.createCollection(STEPS_COLLECTION)
  await db.createCollection(USERS_COLLECTION)
  await db.createCollection(CODES_COLLECTION)
  await db.createCollection(AGGREGATED_STEPS_COLLECTION)
}

const register = async ({ app, compareDate, endDate, initialDataDate }) => {
  const res = await request(app)
    .post('/register')
    .send({
      compareDate,
      endDate,
      initialDataDate,
    })
    .expect(200)
  return res.body
}

const userWithSteps = async (
  app,
  { compareDate, endDate, daysWithStepsBefore, daysWithStepsAfter, amount = 10 }
) => {
  const from = moment(compareDate).subtract(daysWithStepsBefore, 'days')
  const to = moment(compareDate).add(daysWithStepsAfter, 'days')
  const steps = generateHealthData({
    from,
    to,
    steps: amount,
  })
  const initialDataDate = moment(steps[0].date_from).format('YYYY-MM-DD')
  const lastDate = moment(steps[steps.length - 1].date_from).format(
    'YYYY-MM-DD'
  )
  const user = await register({
    app,
    compareDate,
    endDate: lastDate,
    initialDataDate,
  })

  await request(app)
    .post('/health-data')
    .send({
      id: user._id,
      dataPoints: steps,
      createAggregation: true,
    })
    .expect(200)
  return user
}

const generateStepsForHour = (date, value) =>
  Array.from({ length: 6 }).map((_, i) => {
    const _date = moment(date).add(10 * i, 'minutes')
    return {
      value,
      unit: 'COUNT',
      date_from: moment(_date).subtract(5, 'minutes').valueOf(),
      date_to: moment(_date).add(5, 'minutes').valueOf(),
      data_type: 'STEPS',
      platform: 'test',
    }
  })

const generateHealthData = ({ from, to, steps = 10 }) => {
  const days = moment(to).diff(moment(from), 'days') + 1
  const hours = 24

  let dataPoints = []
  for (let day = 0; day < days; day++) {
    for (let hour = 0; hour < hours; hour++) {
      const date = moment(from).add(day, 'days').hour(hour)
      dataPoints = [...dataPoints, ...generateStepsForHour(date, steps)]
    }
  }
  return dataPoints
}

module.exports = {
  init,
  cleanup,
  generateHealthData,
  register,
  userWithSteps,
}
