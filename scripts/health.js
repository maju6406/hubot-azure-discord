// Description:
//   Health check endpoint to keep the Azure Web App alive on Free tier.
//
// URLs:
//   GET /health - returns 200 OK with JSON status

'use strict'

module.exports = (robot) => {
  robot.router.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() })
  })
}
