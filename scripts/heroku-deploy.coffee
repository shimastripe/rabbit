# Description:
#   heroku deploy done notification
#
# Dependencies:
#   None
#
# Commands:
#   None
#
# Author:
#   Go Takagi

HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM = process.env.HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM

module.exports = (robot) ->

	unless HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM?
		robot.logger.warning 'Required HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM environment.'
		return

	robot.router.post '/heroku/slash', (req, res) ->
		return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY
		if req.body.challenge?
			# Verify
			challenge = req.body.challenge
			return res.json challenge: challenge

		robot.logger.debug "Call /notify-deploy command."
		notifyList = robot.brain.get('DEPLOY_NOTIFY_LIST') or {}
		console.log notifyList

		payload = req.body
		notifyList.payload.channel_id = payload.text
		robot.brain.set notifyList
		robot.messageRoom payload.channel_id, 'Update deploy notification status in this channel.'

		res.end

	robot.router.post '/heroku/deploy-done', (req, res) ->
		attachment = {}

		# color = good, warning, danger
		if res.statusCode is 200
			msg = "[deploy] done - #{req.body.app}(#{req.body.release})"
			attachment = {
				text: msg
				fallback: msg
				color: 'good'
				mrkdwn_in: ['text']
				}
		else if (res.statusCode is 500) or (res.statusCode is 503)
			# deploy失敗してるとそもそもこれを受け取れないから考えないといけない
			msg = "[deploy] crashed - #{req.body.app}(#{req.body.release})"
			attachment = {
				text: msg
				fallback: msg
				color: 'danger'
				mrkdwn_in: ['text']
				}

		robot.messageRoom HUBOT_SLACK_DEPLOY_DONE_NOTIFICATION_ROOM, {attachments: [attachment]}
		res.end
