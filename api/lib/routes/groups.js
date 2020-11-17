const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')

router.get('/:code', async (req, res) => {
  const { code } = req.params

  const group = await db.getGroupFromCode({ code })

  res.send(group)
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

router.post('/', async (req, res) => {
  const { name } = req.body

  const group = await db.createGroup({ name })

  res.send(group)
})

module.exports = router
