const express = require('express')
const router = express.Router()
const db = require('./adapters/db')

const reqToken = (req, res, next) => {
  const token = req.headers['Authorization']
  if (token !== process.env.DASHBOARD_AUTH_TOKEN) {
    throw new Error('not authed')
  }
  next()
}

router.get('/numUsers', reqToken, (req, res) => {
  res.json(db.getAllUsers().length)
})

router.get('/totalSteps', reqToken, (req, res) => {
  res.json(db.getTotalSteps())
})

router.get('/userRegistrations', reqToken, (req, res) => {
  res.json(db.getAllUsers().map(({ created }) => created))
})

module.exports = router
