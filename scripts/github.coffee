Webhook2Observable = require './webhook'

module.exports = (robot) ->
	webhook2observable = new Webhook2Observable robot

	webhook2observable.simpleHook()
	.subscribe (req ,res) ->
		robot.messageRoom process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM, "First"

	webhook2observable.simpleHook()
	.subscribe (req ,res) ->
		robot.messageRoom process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM, "Second"
