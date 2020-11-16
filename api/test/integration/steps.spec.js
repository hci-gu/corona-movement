const request = require('supertest')
const moment = require('moment')

const app = require(`${process.cwd()}/lib/app.js`)
const testHelper = require('./testHelper')
const { expect } = require('chai')

describe('#Steps', () => {
  let user
  let from = '2020-01-01'
  let to = '2020-01-04'

  describe('POST /health-data', () => {
    beforeEach(async () => {
      user = await testHelper.register({
        app,
        compareDate: '2020-01-02',
        endDate: to,
      })
    })

    it('can upload steps', () =>
      request(app)
        .post('/health-data')
        .send({
          id: user._id,
          dataPoints: testHelper.generateHealthData({
            from,
            to,
          }),
          createAggregation: true,
        })
        .expect(200))
  })

  describe('GET /:id/hours', () => {
    beforeEach(async () => {
      user = await testHelper.userWithSteps(app, {
        compareDate: '2020-01-02',
        endDate: to,
        daysWithStepsBefore: 3,
        daysWithStepsAfter: 3,
      })
    })

    it('can fetch uploaded steps per hour', async () => {
      const res = await request(app).get(`/${user._id}/hours`).expect(200)
      expect(res.body.result[0]).to.eql({
        _id: '2020-01-01 01',
        key: '2020-01-01 01',
        value: 60,
      })
    })

    it('pads days with empty data', async () => {
      const res = await request(app).get(`/${user._id}/hours`).expect(200)
      const today = moment().format('YYYY-MM-DD')
      expect(res.body.result[res.body.result.length - 1]).to.eql({
        _id: `${today} 00`,
        key: `${today} 00`,
        value: 0,
      })
    })
  })

  describe('GET /:id/summary', () => {
    before(async () => {
      user = await testHelper.userWithSteps(app, {
        compareDate: moment().subtract(10, 'days').format('YYYY-MM-DD'),
        daysWithStepsBefore: 5,
        daysWithStepsAfter: 5,
      })
      user2 = await testHelper.userWithSteps(app, {
        compareDate: '2020-01-02',
        daysWithStepsBefore: 3,
        daysWithStepsAfter: 3,
        amount: 20,
      })
    })

    it('can get a summary for own hours before and after', async () => {
      const res = await request(app).get(`/${user._id}/summary`).expect(200)
      expect(res.body.user.before).to.eql(1 * 24 * 6 * 10)
    })
  })

  // after(() => testHelper.cleanup())
})
