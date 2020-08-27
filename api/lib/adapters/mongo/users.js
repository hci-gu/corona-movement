const { ObjectId } = require('mongodb')
const COLLECTION = 'users'
let collection

const create = async ({ compareDate, endDate, division, code }) => {
  const result = await collection.insert({
    compareDate: new Date(compareDate),
    division,
    code,
    endDate: endDate ? new Date(endDate) : undefined,
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

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  create,
  get,
  update,
  remove,
  getAllExcept,
}
