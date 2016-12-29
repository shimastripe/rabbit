Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot
  slack = new Slack robot

  robot.router.post '/heroku/deploy-done', (req, res) ->
    # color = good, warning, danger
    if res.statusCode is 200
      attachment = slack.generateAttachment 'good',
        text: "[deploy] done - #{req.body.app}(#{req.body.release})"
    else if (res.statusCode is 500) or (res.statusCode is 503)
      attachment = slack.generateAttachment 'danger',
        text: "[deploy] crashed - #{req.body.app}(#{req.body.release})"

    slack.sendAttachment res.envelope.room, attachment
    res.send 'OK'
