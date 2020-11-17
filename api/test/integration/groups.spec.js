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

  after(() => testHelper.cleanup())
})
