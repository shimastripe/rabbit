module.exports = (robot) ->
  robot.router.post "/heroku/deploy-done", (req, res) ->
    robot.messageRoom "process.env.HEROKU_DEPLOY_DONE_NOTIFICATION_USER", "[deploy] done - #{req.body.app}(#{req.body.release})"
    res.send "ok"
