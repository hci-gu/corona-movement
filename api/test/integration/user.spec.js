const request = require('supertest')
const moment = require('moment')

const app = require(`${process.cwd()}/lib/app.js`)
const testHelper = require('./testHelper')
const { expect } = require('chai')

describe('#User', () => {
  describe('/register', () => {
    it('registers a new user', async () => {
      const res = await request(app)
        .post('/register')
        .send({
          compareDate: moment('2020-04-01').format('YYYY-MM-DD'),
          afterPeriods: [
            {
              from: '2020-03-11',
              to: null,
            },
          ],
        })
        .expect(200)
      expect(res.body._id).to.exist
      expect(res.body.compareDate).to.equal('2020-04-01T00:00:00.000Z')
      expect(res.body.afterPeriods).to.eql([
        {
          from: '2020-03-11',
          to: null,
        },
      ])
    })

    it('can register a user without periods or compareDate as non WFH', async () => {
      const res = await request(app)
        .post('/register')
        .send({
          workedFromHome: false,
        })
        .expect(200)
      expect(res.body._id).to.exist
    })

    it('non WFH user gets default before/after periods', async () => {
      const res = await request(app)
        .post('/register')
        .send({
          workedFromHome: false,
        })
        .expect(200)
      expect(res.body._id).to.exist

      const res2 = await request(app).get(`/user/${res.body._id}`).expect(200)
      const user = res2.body
      expect(user.beforePeriods).to.eql([
        {
          from: '2020-01-01',
          to: '2020-03-11',
        },
      ])
      expect(user.afterPeriods).to.eql([
        {
          from: '2020-03-11',
          to: null,
        },
      ])
    })
  })

  describe('/user/:id', () => {
    let userId

    before(async () => {
      const res = await request(app)
        .post('/register')
        .send({
          compareDate: moment('2020-04-01').format('YYYY-MM-DD'),
          afterPeriods: [
            {
              from: '2020-03-11',
              to: null,
            },
          ],
        })

      userId = res.body._id
    })

    it('can get a registered user', async () => {
      const res = await request(app).get(`/user/${userId}`).expect(200)

      expect(res.body._id).to.eql(userId)
    })

    it('can patch a user with updated compareDate', async () => {
      const res = await request(app).get(`/user/${userId}`).expect(200)

      expect(res.body.compareDate).to.equal('2020-04-01T00:00:00.000Z')

      const updated = await request(app)
        .patch(`/user/${userId}`)
        .send({
          compareDate: moment('2020-04-02').format('YYYY-MM-DD'),
        })
        .expect(200)
      expect(updated.body.compareDate).to.equal('2020-04-01T00:00:00.000Z')
    })

    it('can patch a user with updated afterPeriods', async () => {
      const res = await request(app).get(`/user/${userId}`).expect(200)

      expect(res.body.afterPeriods).to.eql([
        {
          from: '2020-03-11',
          to: null,
        },
      ])

      await request(app)
        .patch(`/user/${userId}`)
        .send({
          afterPeriods: [
            {
              from: '2020-04-01',
              to: null,
            },
          ],
        })
        .expect(200)

      const updated = await request(app).get(`/user/${userId}`).expect(200)
      expect(updated.body.afterPeriods).to.eql([
        {
          from: '2020-04-01',
          to: null,
        },
      ])
    })
  })

  describe('DELETE /user/:id', () => {
    let userId

    before(async () => {
      const res = await request(app)
        .post('/register')
        .send({
          compareDate: moment('2020-04-01').format('YYYY-MM-DD'),
        })

      userId = res.body._id
    })

    it('can get a registered user', async () => {
      const res = await request(app).get(`/user/${userId}`).expect(200)

      expect(res.body._id).to.eql(userId)
    })

    it('can delete user', () =>
      request(app).delete(`/user/${userId}`).expect(200))

    it('can not get deleted user', () =>
      request(app).delete(`/user/${userId}`).expect(404))
  })

  after(() => testHelper.cleanup())
})
