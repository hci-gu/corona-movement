const express = require('express')
const router = express.Router()

const sfhEvents = (language) => {
  if (language === 'sv') {
    return [
      {
        date: '2020-03-18',
        text: 'Distansundervisning börjar.',
      },
      {
        date: '2020-04-02',
        text: 'Distansundervisning avbryts för gymnasieskolorna.',
      },
      {
        date: '2020-08-17',
        text: 'Skolorna öppnar efter sommarlovet.',
      },
      {
        date: '2020-12-07',
        text: 'Gymnasieskolorna stänger återigen.',
      },
    ]
  }
  return [
    {
      date: '2020-03-18',
      text: 'Distance education starts.',
    },
    {
      date: '2020-04-02',
      text: 'Distance education is canceled for high scool.',
    },
    {
      date: '2020-08-17',
      text: 'The schools open after the summer holidays.',
    },
    {
      date: '2020-12-07',
      text: 'High schools close again',
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
