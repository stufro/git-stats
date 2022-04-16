import app from "../backend/server"
import request from "supertest"

describe('GET /user/:name', () => {
  it('returns the user from github', async () => {
    const res = await request(app)
      .get('/.netlify/functions/server/user/stufro')
      .send()
    expect(res.statusCode).toEqual(200)
    expect(res.body).toHaveProperty('name')
  })
})