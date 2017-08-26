# Description:
#   heroku deploy done notification
#
# Dependencies:
#   None
#
# Commands:
#   /notify-deploy-register <flag>
#   /notify-deploy-list
#
# Author:
#   Go Takagi

{EventEmitter} = require 'events'

module.exports = (robot) ->

	robot.router.post '/slash/heroku/register', (req, res) ->
		return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY
		if req.body.challenge?
			# Verify
			challenge = req.body.challenge
			return res.json challenge: challenge

		robot.logger.debug "Call /notify-deploy command."
		notifyList = robot.brain.get('DEPLOY_NOTIFY_LIST') or {}

		payload = req.body
		flag = payload.text == 'true'
		notifyList[payload.channel_id] = flag
		robot.brain.set 'DEPLOY_NOTIFY_LIST', notifyList
		res.send 'Update deploy notification status in this channel: ' + flag

	robot.router.post '/slash/heroku/list', (req, res) ->
		return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY
		if req.body.challenge?
			# Verify
			challenge = req.body.challenge
			return res.json challenge: challenge

		robot.logger.debug "Call /notify-deploy-list command."
		notifyList = robot.brain.get('DEPLOY_NOTIFY_LIST') or {}

		payload = req.body
		channelFlag = notifyList[payload.channel_id] or false
		res.send channelFlag

	robot.router.post '/heroku/deploy-done', (req, res) ->
		robot.brain.once 'loaded', () =>
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

			notifyList = robot.brain.get('DEPLOY_NOTIFY_LIST') ? {}
			Object.keys(notifyList).forEach (key) ->
				val = @[key]
				if val
					robot.messageRoom key, {attachments: [attachment]}
			, notifyList
			res.end()
