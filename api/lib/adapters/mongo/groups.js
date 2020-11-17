const COLLECTION = 'groups'
const { ObjectId } = require('mongodb')
const { nanoid } = require('nanoid')

let collection

const create = async ({ name }) => {
  const group = await collection.insert({ name, code: nanoid(8) })

  return group.ops[0]
}

const getGroupFromCode = async ({ code }) => collection.findOne({ code })

const get = (id) => collection.findOne({ _id: ObjectId(id) })

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  create,
  getGroupFromCode,
  get,
}
