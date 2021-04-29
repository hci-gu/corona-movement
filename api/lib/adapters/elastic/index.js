const { Client } = require('@elastic/elasticsearch')
const elastic = new Client({ node: 'http://localhost:9200' })

const indices = ['steps', 'daily-steps', 'day-steps', 'users']

const indexExists = async (index) => {
  const res = await elastic.indices.exists({ index })
  return res.body
}

const createIndex = async (index) => {
  if (await indexExists(index)) {
    return
  }
  let properties
  switch (index) {
    case 'steps':
      properties = {
        id: { type: 'keyword' },
        value: { type: 'integer' },
        date: { type: 'date' },
        duration: { type: 'integer' },
        platform: { type: 'keyword' },
      }
      break
    case 'day-steps':
      properties = {
        id: { type: 'keyword' },
        value: { type: 'integer' },
        day: { type: 'integer' },
        hour: { type: 'integer' },
        isAfter: { type: 'bool' },
        ageRange: { type: 'keyword' },
        gender: { type: 'keyword' },
        country: { type: 'keyword' },
        dataSource: { type: 'keyword' },
        stepsChange: { type: 'double' },
      }
    case 'daily-steps':
      properties = {
        id: { type: 'keyword' },
        value: { type: 'integer' },
        date: { type: 'date' },
        created: { type: 'date' },
        ageRange: { type: 'keyword' },
        gender: { type: 'keyword' },
        country: { type: 'keyword' },
        dataSource: { type: 'keyword' },
        stepsChange: { type: 'double' },
      }
    case 'users':
      properties = {
        initialDataDate: { type: 'date' },
        compareDate: { type: 'date' },
        created: { type: 'date' },
        os: { type: 'keyword' },
        dataSource: { type: 'keyword' },
        ageRange: { type: 'keyword' },
        country: { type: 'keyword' },
        education: { type: 'keyword' },
        gender: { type: 'keyword' },
        occupation: { type: 'keyword' },
        stepsBefore: { type: 'integer' },
        stepsAfter: { type: 'integer' },
        stepsEstimate: { type: 'double' },
        stepsChange: { type: 'double' },
        estimationDifference: { type: 'double' },
        estimationResult: { type: 'keyword' },
        estimatedWrong: { type: 'bool' },
        estimatedHigher: { type: 'bool' },
        estimatedLower: { type: 'bool' },
        daysWithData: { type: 'integer' },
        period: { type: 'integer' },
        missingDays: { type: 'integer' },
        totalSteps: { type: 'integer' },
        wfhPeriods: { type: 'integer' },
      }
    default:
      return
      break
  }
  await elastic.indices.create({ index })
  await elastic.indices.putMapping({
    index,
    body: {
      properties,
    },
  })
}

const saveSteps = async (dataPoints) => {
  await elastic.bulk({
    index: 'steps',
    body: dataPoints.flatMap((doc) => [
      { index: { _index: 'steps', _id: `${doc.id}_${doc.date}` } },
      {
        id: doc.id,
        value: doc.value,
        date: doc.date,
        duration: doc.duration,
        platform: doc.platform,
      },
    ]),
  })
}

const saveAvgSteps = async (dataPoints) => {
  await elastic.bulk({
    index: 'day-steps',
    body: dataPoints.flatMap((doc) => [
      {
        index: {
          _index: 'day-steps',
          _id: `${doc.id}_${doc.day}_${doc.hour}_${
            doc.isAfter ? 'after' : 'before'
          }`,
        },
      },
      doc,
    ]),
  })
}

const saveDailySteps = async (dataPoints) => {
  await elastic.bulk({
    index: 'daily-steps',
    body: dataPoints.flatMap((doc) => [
      {
        index: {
          _index: 'daily-steps',
          _id: `${doc.id}_${doc.date}`,
        },
      },
      doc,
    ]),
  })
}

const saveUsers = async (users) => {
  await elastic.bulk({
    index: 'users',
    body: users.flatMap((doc) => [
      { index: { _index: 'users', _id: doc.id } },
      doc,
    ]),
  })
}

module.exports = {
  createIndex: () => Promise.all(indices.map(createIndex)),
  saveSteps,
  saveAvgSteps,
  saveDailySteps,
  saveUsers: async (users) => {
    const mappedUsers = (
      await Promise.all(
        users.map(async (u) => {
          const estimationDifference = u.stepsEstimate - u.stepsChange

          let compareDate
          if (u.compareDate) {
            compareDate = u.compareDate
          } else if (u.afterPeriods && u.afterPeriods.length) {
            compareDate = u.afterPeriods[0].from
          }

          return {
            id: u._id,
            initialDataDate: u.initialDataDate,
            compareDate: u.compareDate,
            created: u.created,
            os: u.os,
            dataSource: u.dataSource,
            ageRange: u.ageRange,
            country: u.country,
            education: u.education,
            gender: u.gender,
            occupation: u.occupation,
            stepsBefore: u.stepsBefore,
            stepsAfter: u.stepsAfter,
            stepsEstimate: u.stepsEstimate.toFixed(2),
            stepsChange: u.stepsChange.toFixed(2),
            estimationDifference: estimationDifference.toFixed(2),
            estimatedWrong: u.estimatedWrong,
            estimatedHigher: u.estimatedHigher,
            estimatedLower: u.estimatedLower,
            daysWithData: u.daysWithData,
            period: u.period,
            missingDays: u.missingDays,
            totalSteps: u.totalSteps,
            wfhPeriods: u.wfhPeriods,
          }
        })
      )
    ).filter((u) => {
      return u.stepsBefore > 0 && u.stepsAfter > 0
    })
    await saveUsers(mappedUsers)
  },
}
