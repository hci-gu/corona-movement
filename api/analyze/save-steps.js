const elastic = require('../lib/adapters/elastic/index')

let localDB, total
const LIMIT = 5000
const saveSteps = async (offset = 0) => {
  const res = await localDB
    .collection('steps')
    .find({})
    .limit(LIMIT)
    .skip(offset * LIMIT)
    .toArray()
  console.log('sync, ', res.length, 'total, ', total)
  if (res.length > 0) {
    await elastic.saveSteps(res)

    total += res.length
    return saveSteps(offset + 1)
  }
}

const run = async (db) => {
  console.log('save-steps: start')
  localDB = db

  await saveSteps()
  console.log('save-steps: done')
}

module.export = run
