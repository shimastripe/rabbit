# Description:
#   slack slash command
#
# Dependencies:
#   None
#
# Commands:
#   /rabbit-delete <count> - delete the latest <count> message of hubot
#   /rabbit-joke - say a funky comment.
#   /rabbit-help - return a slash command list
#
# Author:
#   Go Takagi

# util = require('../lib/util')
# Slack = require 'hubot-slack-enhance'
#
# module.exports = (robot) ->
#
# 	unless Slack.isSlackAdapter robot
# 		robot.logger.warning 'It is a function of Slack Adapter only.'
# 		return
#
# 	slack = Slack.getInstance robot
#
# 	slack.slash.on 'delete', (option, cb)->
# 		command = option.text.split(' ')
# 		cnt = parseInt(command[1], 10) or 100
# 		slack.deleteMessage option.channel.id, cnt, (cnt)->
# 			cb "#{cnt}messages was deleted."
#
# 	slack.slash.on 'joke', (option, cb)->
# 		cb "#{util.joke()}", {response_type: "in_channel"}
#
# 	slack.slash.on 'help', (option, cb)->
# 		cb """
# 		Valid commands: delete, help.
#
# 		To delete the latest <count> message of hubot: /rabbit-delete <count>
# 		To say a funcy comment. : /rabbit-joke
# 		To return a slash command list: /rabbit-help
# 		"""
