const COLLECTION = 'codes'
let collection

const codeExists = async (code) => {
  const doc = await collection.findOne({ code })
  return !!doc
}

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  codeExists,
}
