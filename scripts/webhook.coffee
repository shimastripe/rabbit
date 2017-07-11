Slack = require 'hubot-slack-enhance'
NOTIFICATION_ROOM = process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM

module.exports = (robot) ->
	unless NOTIFICATION_ROOM?
		robot.logger.warning 'Required HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM environment.'
		return

	robot.router.post '/webhook/github', (req, res) ->
		attachment = slack.generateAttachment 'good',
			fallback: ""
			text: "Webhook comming"
		robot.messageRoom NOTIFICATION_ROOM, [attachment]
		res.send 'OK'
