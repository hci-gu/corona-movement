const request = require('supertest')
const moment = require('moment')

const app = require(`${process.cwd()}/lib/app.js`)
const testHelper = require('./testHelper')

describe('#User', () => {
  describe('/register', () => {
    it('registers a new user', async () => {
      const res = await request(app)
        .post('/register')
        .send({
          compareDate: moment('2020-04-01').format('YYYY-MM-DD'),
        })
        .expect(200)
      expect(res.body._id).to.exist
      expect(res.body.compareDate).to.equal('2020-04-01T00:00:00.000Z')
    })
  })

  describe('/user/:id', () => {
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
