const moment = require('moment')
const AWS = require('aws-sdk')
const COLLECTION = 'feedback'
const {
  AWS_S3_ACCESS_KEY_ID,
  AWS_S3_ACCESS_KEY_SECRET,
  AWS_S3_BUCKET_NAME,
  AWS_S3_BUCKET_REGION,
} = process.env

let collection
AWS.config.update({ region: AWS_S3_BUCKET_REGION })

const s3 = new AWS.S3({
  accessKeyId: AWS_S3_ACCESS_KEY_ID,
  secretAccessKey: AWS_S3_ACCESS_KEY_SECRET,
  region: AWS_S3_BUCKET_REGION,
  signatureVersion: 'v4',
})

module.exports = {
  init: async (db) => {
    await db.createCollection(COLLECTION)
    collection = db.collection(COLLECTION)
  },
  collection,
  uploadFeedback: async (options) => {
    const fileName = `${moment().format('YYYY-DD-MMTHH-mm-SS')}.png`
    const s3Params = {
      Bucket: AWS_S3_BUCKET_NAME,
      Key: `wfhmovement/${fileName}`,
      Expires: 60 * 60,
      ContentType: 'image/png',
    }

    await collection.insert({
      image: `https://${AWS_S3_BUCKET_NAME}.s3.amazonaws.com/wfhmovement/${fileName}`,
      ...options,
    })

    const url = await s3.getSignedUrl('putObject', s3Params)

    return url
  },
}
