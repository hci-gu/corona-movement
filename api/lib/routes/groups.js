const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')

router.get('/:id', async (req, res) => {
  const { id } = req.params

  const group = await db.getGroup(id)

  res.send(group)
})

router.get('/code/:code', async (req, res) => {
  const { code } = req.params

  const group = await db.getGroupFromCode({ code })

  res.send(group)
})

router.delete('/:id/:userId', async (req, res) => {
  const { id, userId } = req.params

  try {
    await db.leaveGroup({ id: userId, groupId: id })
    return res.sendStatus(200)
  } catch (e) {
    return res.sendStatus(400)
  }
})

router.post('/:id/join', async (req, res) => {
  const { id } = req.params
  const { userId } = req.body

  try {
    await db.joinGroup({
      id: userId,
      groupId: id,
    })
    res.sendStatus(200)
  } catch (err) {
    res.sendStatus(404)
  }
})
router.post('/join-multiple', async (req, res) => {
  const { ids, userId } = req.body

  try {
    await db.joinGroups({
      id: userId,
      groupIds: ids,
    })
    res.sendStatus(200)
  } catch (err) {
    res.sendStatus(404)
  }
})

router.post('/', async (req, res) => {
  const { name } = req.body

  const group = await db.createGroup({ name })

  res.send(group)
})

module.exports = router
