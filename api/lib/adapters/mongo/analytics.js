const COLLECTION = 'analytics'

let collection

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  count: async ({ event, from = new Date('2020-01-01') }) =>
    collection.count({ event, date: { $gt: from } }),
  saveEvent: async (body) => {
    await collection.insert({
      date: new Date(),
      ...body,
    })
  },
  removeAnalyticsForUser: async (userId) => {
    await collection.deleteMany({ userId })
    await collection.insert({
      date: new Date(),
      event: 'deleteAccount',
    })
  },
}
