const COLLECTION = 'aggregated-users'
let collection

const getUsers = ({ offset = 0, limit = 100 }) =>
  collection
    .find()
    .limit(limit)
    .skip(offset * limit)
    .toArray()

const saveUser = (user) => collection.insert(user)

const clearUsers = () => collection.deleteMany({})

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  saveUser,
  clearUsers,
  getUsers,
}
