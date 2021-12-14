require('dotenv').config()

const axios = require('axios')
const moment = require('moment')

const DATASET_NAME = '24-before-24-after'
const DATASET_ID = `${DATASET_NAME}-${moment().format('YYYY-MM-DD')}`
const LIMIT = 100

const wait = (timeout) =>
  new Promise((resolve) => setTimeout(() => resolve(), timeout))

const api = axios.create({
  baseURL: process.env.API_URL,
  headers: {
    Authorization: process.env.DASHBOARD_AUTH_TOKEN,
  },
})

const fill = async (offset = 0) => {
  console.time('fill_' + offset)
  console.log('fill', offset)
  try {
    await api.post(
      `/analytics/dataset/${DATASET_ID}/rows?offset=${offset}&limit=${LIMIT}`
    )
  } catch (e) {
    console.log(e)
    await wait(1000)
    process.exit(0)
  }
  console.timeEnd('fill_' + offset)
  return fill(offset + 1)
}

const run = async () => {
  await api.post(`/analytics/dataset/${DATASET_ID}`)

  await fill()
}

run()
