Slack = require 'hubot-slack-enhance'
NOTIFICATION_ROOM = process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM

module.exports = (robot) ->
	unless NOTIFICATION_ROOM?
		robot.logger.warning 'Required HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM environment.'
		return

	unless Slack.isSlackAdapter robot
		robot.logger.warning 'It is a function of Slack Adapter only.'
		return

	slack = Slack.getInstance robot

	robot.router.post '/webhook/github', (req, res) ->
		attachment = slack.generateAttachment 'good',
			fallback: ""
			text: "Webhook comming"
		slack.sendAttachment NOTIFICATION_ROOM, [attachment]
		res.send 'OK'
