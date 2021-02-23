const { ObjectId } = require('mongodb')
const { FROM_DATE, BEFORE_END_DATE } = require('../../constants')
const moment = require('moment')
const COLLECTION = 'users'
let collection

const groupsCollection = require('./groups')

const create = async ({
  initialDataDate,
  compareDate,
  endDate,
  os,
  dataSource,
  code,
  beforePeriods,
  afterPeriods,
  workedFromHome,
}) => {
  const result = await collection.insert({
    created: new Date(),
    compareDate: compareDate ? new Date(compareDate) : undefined,
    initialDataDate: new Date(initialDataDate),
    endDate: endDate ? new Date(endDate) : undefined,
    beforePeriods,
    afterPeriods,
    os,
    dataSource,
    code,
    workedFromHome,
  })
  return result.ops[0]
}

const get = async (id) => collection.findOne({ _id: ObjectId(id) })

const update = async ({ id, update }) => {
  const _update = Object.keys(update).reduce((obj, key) => {
    if (key === 'compareDate' || key == 'initialDataDate') {
      obj[key] = new Date(update[key])
    } else {
      obj[key] = update[key]
    }
    return obj
  }, {})
  const result = await collection.findOneAndUpdate(
    { _id: ObjectId(id) },
    { $set: _update }
  )
  return result.value
}

const remove = async (id) => {
  const res = await collection.deleteOne({ _id: ObjectId(id) })
  return res.deletedCount === 1
}

const getAllExcept = async (id, code) => {
  if (code) {
    return collection.find({ _id: { $ne: ObjectId(id) }, code }).toArray()
  }
  return collection.find({ _id: { $ne: ObjectId(id) } }).toArray()
}

const insert = (d) => collection.insert(d)

const usersInGroup = async (groupId) =>
  collection.find({ group: groupId }).toArray()

const joinGroup = async ({ id, groupId }) => {
  const group = await groupsCollection.get(groupId)

  if (!group) {
    throw new Error('Group not found')
  }

  return update({ id, update: { group: groupId } })
}

const leaveGroup = async ({ id, groupId }) =>
  collection.update({ _id: ObjectId(id) }, { $unset: { group: 1 } })

const beforePeriodsForUser = (user) => {
  let to = user.compareDate ? user.compareDate : BEFORE_END_DATE
  if (user.afterPeriods && user.afterPeriods.length) {
    to = user.afterPeriods[0].from
  }

  return [
    {
      from: moment(user.initialDataDate).isAfter(FROM_DATE)
        ? user.initialDataDate
        : FROM_DATE,
      to,
    },
  ]
}

module.exports = {
  init: async (db) => {
    if (process.env.NODE_ENV != 'production')
      await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  insert,
  collection,
  create,
  get: async (id) => {
    const user = await get(id)
    if (user) {
      user.beforePeriods = beforePeriodsForUser(user)
      if (user.workedFromHome === false) {
        user.afterPeriods = [
          {
            from: BEFORE_END_DATE,
            to: null,
          },
        ]
        return user
      }

      if (!user.afterPeriods) {
        user.afterPeriods = [
          {
            from: user.compareDate,
            to: null,
          },
        ]
      }
    }
    return user
  },
  update,
  remove,
  getAllExcept,
  joinGroup,
  leaveGroup,
  usersInGroup,
  count: ({ from = new Date('2020-01-01') }) =>
    collection.count({ created: { $gt: from } }),
  beforePeriodsForUser,
}
