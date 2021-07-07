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
  getEventsForUser: async (userId) => {
    const result = await collection.find({ userId }).toArray()

    if (!result.length) {
      return null
    }

    return result.reduce((acc, curr) => {
      if (acc[curr.event]) {
        acc[curr.event]++
      } else {
        acc[curr.event] = 1
      }
      return acc
    }, {})
  },
  removeAnalyticsForUser: async (userId) => {
    await collection.deleteMany({ userId })
    await collection.insert({
      date: new Date(),
      event: 'deleteAccount',
    })
  },
}
