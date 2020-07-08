const { ObjectId } = require('mongodb')
const COLLECTION = 'users'
let collection

const create = async ({ compareDate, division }) => {
  const result = await collection.insert({
    compareDate: new Date(compareDate),
    division,
  })
  return result.ops[0]
}

const get = async (id) => collection.findOne({ _id: ObjectId(id) })

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

const getAllExcept = async (id) =>
  collection.find({ _id: { $ne: ObjectId(id) } }).toArray()

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  create,
  get,
  update,
  getAllExcept,
}
