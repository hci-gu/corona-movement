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
    if (!body.userId) {
      return
    }

    await collection.insert({
      date: new Date(),
      ...body,
    })
  },
}
