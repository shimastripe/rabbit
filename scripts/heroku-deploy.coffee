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
    # color = good, warning, danger
    console.log(res.statusCode)
    if res.statusCode is 200
      attachment = slack.generateAttachment 'good',
        text: "[deploy] done - #{req.body.app}(#{req.body.release})"
    else if (res.statusCode is 500) or (res.statusCode is 503)
      attachment = slack.generateAttachment 'danger',
        text: "[deploy] crashed - #{req.body.app}(#{req.body.release})"

    slack.sendAttachment HEROKU_DEPLOY_DONE_NOTIFICATION_ROOM, attachment
    res.send 'OK'
