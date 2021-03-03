const express = require('express')
const router = express.Router()

const sfhEvents = (language) => {
  if (language === 'sv') {
    return [
      {
        date: '2020-03-16',
        text: 'Rekommendationer att studera hemifrån.',
      },
    ]
  }
  return [
    {
      date: '2020-03-16',
      text: 'Swedish recommendations to study from home.',
    },
  ]
}

const wfhEvents = (language) => {
  if (language === 'sv') {
    return [
      {
        date: '2020-03-16',
        text: 'Rekommendationer att arbeta hemifrån.',
      },
    ]
  }
  return [
    {
      date: '2020-03-16',
      text: 'Swedish recommendations to work from home.',
    },
  ]
}

router.get('/', async (req, res) => {
  const { language } = req.headers
  if (req.headers['app-name'] === 'SFH Movement') {
    return res.send(sfhEvents(language))
  }
  return res.send(wfhEvents(language))
})

module.exports = router
