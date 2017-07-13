Webhook2Observable = require './webhook'

module.exports = (robot) ->
	webhook2observable = Webhook2Observable robot
	webhook2observable().subscribe (req ,res) ->
		robot.messageRoom process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM, "First"
	webhook2observable().subscribe (req ,res) ->
		robot.messageRoom process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM, "Second"
