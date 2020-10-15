const { ObjectId } = require('mongodb')
const stepsCollection = require('./steps')
const COLLECTION = 'users'
let collection

const create = async ({
  initialDataDate,
  compareDate,
  endDate,
  os,
  dataSource,
  code,
}) => {
  const result = await collection.insert({
    created: new Date(),
    compareDate: new Date(compareDate),
    initialDataDate: new Date(initialDataDate),
    endDate: endDate ? new Date(endDate) : undefined,
    os,
    dataSource,
    code,
  })
  return result.ops[0]
}

const get = async (id) => {
  const user = await collection.findOne({ _id: ObjectId(id) })
  if (user && user.stepsEstimate) {
    user.stepsEstimate = user.stepsEstimate + 0.000000001
  }
  return user
}

const update = async ({ id, update }) => {
  const _update = Object.keys(update).reduce((obj, key) => {
    if (key === 'compareDate' || key == 'initialDataDate') {
      obj[key] = new Date(update[key])
    } else {
      obj[key] = update[key]
    }
    return obj
  }, {})
  const result = await collection.findOneAndUpdate(
    { _id: ObjectId(id) },
    { $set: _update }
  )
  return result.value
}

const remove = async (id) => {
  const res = await collection.deleteOne({ _id: ObjectId(id) })
  return res.deletedCount === 1
}

const getAllExcept = async (id, code) => {
  if (code) {
    return collection.find({ _id: { $ne: ObjectId(id) }, code }).toArray()
  }
  return collection.find({ _id: { $ne: ObjectId(id) } }).toArray()
}

const insert = (d) => collection.insert(d)

const getInitialDataDate = async (id) => {
  const user = await get(id)

  if (!user.initialDataDate) {
    user.initialDataDate = new Date(
      (await stepsCollection.getFirstUpload({ id })).date
    )
  }

  if (user) return user.initialDataDate
}

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  insert,
  collection,
  create,
  get,
  update,
  remove,
  getAllExcept,
  getInitialDataDate,
}
