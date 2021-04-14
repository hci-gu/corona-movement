const elastic = require('../lib/adapters/elastic/index')
const userUtils = require('./user-utils')

const run = async (db) => {
  console.log('save-users: start')
  userUtils.init(db)

  const users = await userUtils.getUsers()
  await elastic.saveUsers(users)
  console.log('save-users: done')
}

module.exports = run
