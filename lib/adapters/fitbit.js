const Oauth2 = require('simple-oauth2').create

const PORT = process.env.PORT ? process.env.PORT : 3000
const options = {
  scope:
    'activity heartrate location nutrition profile settings sleep social weight',
  redirect_uri: `http://localhost:${PORT}/callback`,
  state: 'fitbit',
}

const oauth = Oauth2({
  client: {
    id: process.env.FITBIT_CLIENT_ID,
    secret: process.env.FITBIT_CLIENT_SECRET,
  },
  auth: {
    tokenHost: 'https://api.fitbit.com/',
    tokenPath: 'oauth2/token',
    revokePath: 'oauth2/revoke',
    authorizeHost: 'https://api.fitbit.com/',
    authorizePath: 'oauth2/authorize',
  },
})

const getAccessToken = async (code) => {
  return new Promise((resolve, reject) => {
    oauth.authorizationCode.getToken(
      {
        code,
        redirect_uri: options.redirect_uri,
        scope: options.scope,
      },
      (error, result) => {
        if (error) {
          reject(error)
        } else {
          resolve(result)
        }
      }
    )
  })
}

module.exports = {
  redirect: (res) =>
    res.redirect(
      oauth.authorizationCode.authorizeURL(options).replace('api', 'www')
    ),
  handleCallback: async (req) => {
    let result
    try {
      result = await getAccessToken(req.query.code)
    } catch (e) {
      return res.send(e)
    }
    const token = this.oauth2.accessToken.create({
      access_token: result.access_token,
      refresh_token: result.access_token,
      expires_in: result.expires_in,
    })
    return token
  },
}
