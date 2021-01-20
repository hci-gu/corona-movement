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

module.exports = {
  promiseSeries,
  getPercentageChange,
  userEstimatedWrong,
  estimatedHigherThanResult,
  estimatedLowerThanResult,
}
