const COLLECTION = 'analytics'

let collection

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  saveEvent: async (body) => {
    await collection.insert({
      date: new Date(),
      ...body,
    })
  },
}
