const request = require('supertest')
const moment = require('moment')

const app = require(`${process.cwd()}/lib/app.js`)
const testHelper = require('./testHelper')

describe('#Group', () => {
  let group
  before(async () => {
    const response = await request(app)
      .post('/groups')
      .send({ name: 'test' })
      .expect(200)
    group = response.body
  })

  describe('GET /groups/:code', () => {
    it('can get a group for its code', async () => {
      const res = await request(app).get(`/groups/${group.code}`).expect(200)
      expect(res.body._id).to.exist
    })

    it("gets null if code doesn't match group", async () => {
      const res = await request(app).get('/groups/does-not-exist').expect(200)
      expect(res.body).to.be.empty
    })
  })

  describe('Joining a group', () => {
    let user, group

    before(async () => {
      user = await testHelper.userWithSteps(app, {
        compareDate: moment().subtract(10, 'days').format('YYYY-MM-DD'),
        daysWithStepsBefore: 5,
        daysWithStepsAfter: 5,
      })
      const response = await request(app)
        .post('/groups')
        .send({ name: 'test' })
        .expect(200)
      group = response.body
    })

    it('can join a group', async () => {
      await request(app)
        .post(`/groups/${group._id}/join`)
        .send({ userId: user._id })
        .expect(200)
    })

    it('fails when trying to join a group that does not exist', async () => {
      await request(app)
        .post('/groups/does-not-exist/join')
        .send({ userId: user._id })
        .expect(404)
    })

    it('should include joined group in summary request after user has joined', async () => {
      const response = await request(app)
        .get(`/${user._id}/summary`)
        .expect(200)

      expect(response.body[group.name]).to.exist
    })
  })

  after(() => testHelper.cleanup())
})
