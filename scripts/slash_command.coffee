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
    return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY

    command = req.body.text.split(' ')
    switch command[0]
      when "delete"
        return res.send 'Invalid input [/rabbit delete <count>]' unless command.length is 2

        count = parseInt(command[1], 10) or 0
        console.log(count)
        slack.deleteMessage req.body.channel_id, count
        res.send "#{count}messages was deleted."
      when "help"
        res.send """
        Valid commands: delete, help.

        To delete the latest <count> message of hubot: /rabbit delete <count>
        To return a slash command list: /rabbit help
        """
      else
        res.send 'Valid commands: delete, help.'
