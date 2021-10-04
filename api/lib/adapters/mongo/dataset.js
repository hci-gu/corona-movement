const COLLECTION_PREFIX = 'dataset'
const COLLECTION = 'datasets'
let db

const collectionExists = async (name) => {
  const collections = await db.listCollections({ name }).toArray()
  return collections.length > 0
}

module.exports = {
  init: async (database) => {
    db = database
    await db.createCollection(COLLECTION)
  },
  get: async (id, offset = 0, limit = 100) => {
    const collectionName = `${COLLECTION_PREFIX}-${id}`

    const dataset = await db.collection(COLLECTION).findOne({ id })
    const rows = await db
      .collection(collectionName)
      .find()
      .limit(limit)
      .skip(offset * limit)
      .toArray()
    return {
      ...dataset,
      rows,
    }
  },
  list: () => db.collection(COLLECTION).find().toArray(),
  create: async (id, columns) => {
    const collectionName = `${COLLECTION_PREFIX}-${id}`
    if (await collectionExists(collectionName)) {
      throw new Error(`dataset with id ${id} already exists`)
    }
    await db.createCollection(collectionName)
    await db.collection(COLLECTION).insert({
      id,
      columns,
      created: new Date(),
    })
  },
  fill: async (id, rows) => {
    const collectionName = `${COLLECTION_PREFIX}-${id}`
    const collection = db.collection(collectionName)
    await collection.insertMany(rows)
  },
  remove: async (id) => {
    const collectionName = `${COLLECTION_PREFIX}-${id}`
    await db.collection(collectionName).drop()
    await db.collection(COLLECTION).deleteOne({ id })
  },
}
