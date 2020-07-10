const { MongoClient } = require('mongodb')
const moment = require('moment')

let db
const STEPS_COLLECTION = 'steps'
const USERS_COLLECTION = 'users'
const CODES_COLLECTION = 'codes'

const cleanup = async () => {
  await Promise.all([
    db.collection(USERS_COLLECTION).deleteMany({}),
    db.collection(STEPS_COLLECTION).deleteMany({}),
    db.collection(CODES_COLLECTION).deleteMany({}),
  ])
}

const init = async () => {
  const client = await MongoClient.connect(process.env.CONNECT_TO)
  db = client.db(process.env.DB_NAME)
  await db.createCollection(STEPS_COLLECTION)
  await db.createCollection(USERS_COLLECTION)
  await db.createCollection(CODES_COLLECTION)
}

/*

*/
const generateHealthData = ({
  from,
  to,
  steps = 10,
  platform = 'PlatformType.IOS',
}) => {
  let length = 0
  let diff = moment(to).diff(moment(from))
  while (diff > 0) {
    length++

    to = moment(to).subtract(10, 'minutes')
    diff = moment(to).diff(from)
  }

  return Array.from({ length }).map((_, i) => ({
    value: steps,
    unit: 'COUNT',
    date_from: moment(from)
      .add(i * 10, 'minutes')
      .valueOf(),
    date_to: moment(from)
      .add(i * 10 + 10, 'minutes')
      .valueOf(),
    data_type: 'STEPS',
    platform,
  }))
}

module.exports = {
  init,
  cleanup,
  generateHealthData,
}
