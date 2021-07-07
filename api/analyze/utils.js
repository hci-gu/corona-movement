const { DataSync } = require('aws-sdk')
const moment = require('moment')

const promiseSeries = (items, method) => {
  const results = []

  function runMethod(item) {
    return new Promise((resolve, reject) => {
      method(item)
        .then((res) => {
          results.push(res)
          resolve(res)
        })
        .catch((err) => reject(err))
    })
  }

  return items
    .reduce(
      (promise, item) => promise.then(() => runMethod(item)),
      Promise.resolve()
    )
    .then(() => results)
}

const getPercentageChange = (before, after) => {
  return (after - before) / before
}

const userEstimatedWrong = (estimate, change) => {
  return (estimate > 0 && change < 0) || (estimate < 0 && change > 0)
}

const estimatedHigherThanResult = (estimate, change) => {
  return estimate > change
}

const estimatedLowerThanResult = (estimate, change) => {
  return estimate < change
}

const allDaysForUser = (days) => {
  if (!days || !days.length)
    return {
      period: 0,
      daysWithData: 0,
    }

  const firstDay = days[0].date
  const lastDay = days[days.length - 1].date

  const daysMap = days.reduce((acc, curr) => {
    acc[curr.date] = curr.value
    return acc
  }, {})

  const diff = moment(lastDay).diff(firstDay, 'days')

  let allDays = []
  Array.from({ length: diff }).map((_, i) => {
    const date = moment(firstDay).add(i, 'days').format('YYYY-MM-DD')
    if (daysMap[date]) {
      allDays.push({
        date,
        value: daysMap[date],
      })
    } else {
      allDays.push({
        date,
        value: 0,
      })
    }
  })

  return allDays
}

const translateGender = (gender) => {
  switch (gender) {
    case 'Female':
    case 'Kvinna':
      return 'Female'
    case 'Male':
    case 'Man':
      return 'Male'
    default:
      return gender
  }
}

const translateEducation = (education) => {
  switch (education) {
    case 'Kandidatexamen':
      return "Bachelor's Degree"
    case 'Masterexamen':
      return "Master's Degree"
    case 'Doktorsexamen':
      return 'PhD'
    case 'Yrkeshögskola':
      return 'Trade/Vocational School'
    case 'Ingen högre utbildning':
      return 'No higher education'
    default:
      return education
  }
}

const translateAgeRange = (ageRange) => {
  switch (ageRange) {
    case 'Vill inte uppge':
      return 'Prefer not to say	'
    default:
      return ageRange
  }
}

module.exports = {
  promiseSeries,
  getPercentageChange,
  userEstimatedWrong,
  estimatedHigherThanResult,
  estimatedLowerThanResult,
  allDaysForUser,
  translateGender,
  translateEducation,
  translateAgeRange,
}
