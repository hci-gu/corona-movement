const express = require('express')
const router = express.Router()
const db = require('./adapters/db')

router.get('/numUsers', (req, res) => {
  res.json(db.getAllUsers().length)
})

router.get('/totalSteps', (req, res) => {
  res.json(db.getTotalSteps())
})

router.get('/userRegistrations', (req, res) => {
  res.json(db.getAllUsers().map(({ created }) => created))
})

module.exports = router
