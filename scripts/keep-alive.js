// Description:
//   Self-ping to keep the Azure Web App alive on Free tier.
//   Uses the WEBSITE_HOSTNAME env var set automatically by Azure App Service.

'use strict'

const https = require('https')

module.exports = (robot) => {
  const hostname = process.env.WEBSITE_HOSTNAME
  if (!hostname) {
    robot.logger.debug('WEBSITE_HOSTNAME not set; skipping keep-alive ping')
    return
  }

  const url = `https://${hostname}/health`

  setInterval(() => {
    https.get(url, (res) => {
      robot.logger.debug(`Keep-alive ping: ${res.statusCode}`)
    }).on('error', (err) => {
      robot.logger.error(`Keep-alive ping failed: ${err.message}`)
    })
  }, 4 * 60 * 1000) // every 4 minutes
}
