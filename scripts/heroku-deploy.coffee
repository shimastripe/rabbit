module.exports = (robot) ->
  # import util
  util = require('../lib/util')(robot)

  robot.router.post "/heroku/deploy-done", (req, res) ->
    util.say(process.env.HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM, "[deploy] done - #{req.body.app}(#{req.body.release})", {as_user: false, unfurl_links: false})
    res.send 'OK'
