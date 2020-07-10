const request = require('supertest')
const moment = require('moment')

const app = require(`${process.cwd()}/lib/app.js`)
const testHelper = require('./testHelper')
const { expect } = require('chai')
const { test } = require('mocha')

describe('#Steps', () => {
  let user
  let from = '2020-01-01'
  let to = '2020-01-03'

  before(async () => {
    const res = await request(app)
      .post('/register')
      .send({
        compareDate: moment('2020-01-02').format('YYYY-MM-DD'),
      })
      .expect(200)
    user = res.body
  })

  describe('/health-data', () => {
    it('saves healthdata to steps', async () => {
      const res = await request(app)
        .post('/health-data')
        .send({
          id: user._id,
          dataPoints: testHelper.generateHealthData({
            from,
            to,
          }),
        })
        .expect(200)
    })
  })

  describe('/:id/hours', () => {
    it('can fetch uploaded steps per hour', async () => {
      const res = await request(app)
        .get(`/${user._id}/hours?from=${from}&to=2020-01-02`)
        .expect(200)
      expect(res.body.result.length).to.eql(24)
      expect(res.body.result[0]).to.eql({
        _id: '2020-01-01 01',
        key: '2020-01-01 01',
        value: 60,
      })
    })
  })

  describe('/:id/summary', () => {
    before(async () => {
      // create another user to compare with
      const res = await request(app)
        .post('/register')
        .send({
          compareDate: moment('2020-01-02').format('YYYY-MM-DD'),
        })
        .expect(200)
      await request(app)
        .post('/health-data')
        .send({
          id: res.body._id,
          dataPoints: testHelper.generateHealthData({
            from,
            to,
            steps: 20,
          }),
        })
        .expect(200)
    })

    it('can get a summary for own hours before and after', async () => {
      const res = await request(app).get(`/${user._id}/summary`).expect(200)
      expect(res.body.user.before).to.eql(1 * 24 * 6 * 10)
      expect(res.body.user.after).to.eql(7.354)
    })

    it('can get a summary for own hours before and after', async () => {
      const res = await request(app).get(`/${user._id}/summary`).expect(200)
      expect(res.body.others.before).to.eql(1 * 24 * 6 * 20)
      expect(res.body.others.after).to.eql(14.709)
    })
  })

  after(() => testHelper.cleanup())
})

describe('#Steps uploading same data', () => {
  let user
  let from = '2020-01-01'
  let to = '2020-01-03'

  const uploadSteps = () =>
    request(app)
      .post('/health-data')
      .send({
        id: user._id,
        dataPoints: testHelper.generateHealthData({
          from,
          to,
        }),
      })
      .expect(200)

  before(async () => {
    const res = await request(app)
      .post('/register')
      .send({
        compareDate: moment('2020-01-02').format('YYYY-MM-DD'),
      })
      .expect(200)
    user = res.body

    await uploadSteps()
  })

  it('has expected amount of steps before', async () => {
    const res = await request(app).get(`/${user._id}/summary`).expect(200)
    expect(res.body.user.before).to.eql(1 * 24 * 6 * 10)
    expect(res.body.user.after).to.eql(7.354)
  })

  it('uploads same data again without steps changing', async () => {
    await uploadSteps()

    const res = await request(app).get(`/${user._id}/summary`).expect(200)
    expect(res.body.user.before).to.eql(1 * 24 * 6 * 10)
    expect(res.body.user.after).to.eql(7.354)
  })

  after(() => testHelper.cleanup())
})

describe('#Steps overwriting data', () => {
  let user

  before(async () => {
    const res = await request(app)
      .post('/register')
      .send({
        compareDate: moment('2020-01-02').format('YYYY-MM-DD'),
      })
      .expect(200)
    user = res.body
  })

  it('Will overwrite if new platform has more steps', async () => {
    const first = [
      {
        value: 10,
        date_from: moment('2020-01-01T10:00').valueOf(),
        date_to: moment('2020-01-01T10:10').valueOf(),
        data_type: 'STEPS',
        platform: 'Garmin',
      },
      {
        value: 10,
        date_from: moment('2020-01-01T10:10').valueOf(),
        date_to: moment('2020-01-01T10:20').valueOf(),
        data_type: 'STEPS',
        platform: 'Garmin',
      },
      {
        value: 10,
        date_from: moment('2020-01-01T10:20').valueOf(),
        date_to: moment('2020-01-01T10:30').valueOf(),
        data_type: 'STEPS',
        platform: 'Garmin',
      },
    ]
    await request(app)
      .post('/health-data')
      .send({
        id: user._id,
        dataPoints: first,
      })
      .expect(200)

    const res = await request(app).get(`/${user._id}/summary`).expect(200)
    expect(res.body.user.before).to.eql(30)
    const second = [
      {
        value: 10,
        date_from: moment('2020-01-01T10:00').valueOf(),
        date_to: moment('2020-01-01T10:10').valueOf(),
        data_type: 'STEPS',
        platform: 'PlatformType.IOS',
      },
      {
        value: 20,
        date_from: moment('2020-01-01T10:10').valueOf(),
        date_to: moment('2020-01-01T10:20').valueOf(),
        data_type: 'STEPS',
        platform: 'PlatformType.IOS',
      },
      {
        value: 10,
        date_from: moment('2020-01-01T10:20').valueOf(),
        date_to: moment('2020-01-01T10:30').valueOf(),
        data_type: 'STEPS',
        platform: 'PlatformType.IOS',
      },
    ]

    await request(app)
      .post('/health-data')
      .send({
        id: user._id,
        dataPoints: second,
      })
      .expect(200)

    const res2 = await request(app).get(`/${user._id}/summary`).expect(200)
    expect(res2.body.user.before).to.eql(40)
  })

  after(() => testHelper.cleanup())
})

describe('#Steps overwrite highest value for time', () => {})
