const express = require('express')
const router = express.Router()
const moment = require('moment')
const db = require('../adapters/db')

router.get('/:code', async (req, res) => {
  const { code } = req.params

  const group = await db.getGroupFromCode({ code })

  res.send(group)
})

router.post('/', async (req, res) => {
  const { name } = req.body

  const group = await db.createGroup({ name })

  res.send(group)
})

module.exports = router
