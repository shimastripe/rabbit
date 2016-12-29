Slack = require 'hubot-slack-enhance'

HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM = process.env.HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM

module.exports = (robot) ->

  unless HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM?
    robot.logger.warning 'Required HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM environment.'
    return

  unless Slack.isSlackAdapter robot
    robot.logger.warning 'It is a function of Slack Adapter only.'
    return

  slack = new Slack robot

  robot.router.post '/heroku/deploy-done', (req, res) ->
    attachment = {}

    # color = good, warning, danger
    if res.statusCode is 200
      msg = "[deploy] done - #{req.body.app}(#{req.body.release})"
      attachment = slack.generateAttachment 'good',
        fallback: msg
        text: msg
    else if (res.statusCode is 500) or (res.statusCode is 503)
      msg = "[deploy] crashed - #{req.body.app}(#{req.body.release})"
      attachment = slack.generateAttachment 'danger',
        fallback: msg
        text: msg

    slack.sendAttachment HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM, [attachment]
    res.send 'OK'
