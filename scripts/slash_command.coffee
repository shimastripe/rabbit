# Description:
#   slack slash command
#
# Dependencies:
#   None
#
# Commands:
#   /rabbit delete <count> - delete the latest <count> message of hubot
#   /rabbit help - return a slash command list
#
# Author:
#   Go Takagi

Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->

  unless Slack.isSlackAdapter robot
    robot.logger.warning 'It is a function of Slack Adapter only.'
    return

  slack = new Slack robot

  robot.router.post '/slack/command', (req, res) ->
    console.log(req.envelope.name)
    console.log(req.body.payload)
    res.send 'OK'
