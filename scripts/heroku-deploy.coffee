Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot
  slack = new Slack robot

  robot.router.post "/heroku/deploy-done", (req, res) ->
    attachment = slack.generateAttachment 'good',
      text: "[deploy] done - #{req.body.app}(#{req.body.release})"
    slack.sendAttachment res.envelope.room, attachment
    res.send 'OK'
