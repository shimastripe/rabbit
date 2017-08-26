# Description:
#   switch stock notification
#
# Dependencies:
#   None
#
# Commands:
#   /monitor-switch-register <flag>
#   /monitor-switch-list
#
# Author:
#   Go Takagi

Chromy = require 'chromy'
{CronJob} = require 'cron'

MY_NINTENDO_STORE = 'https://store.nintendo.co.jp/customize.html'

module.exports = (robot) ->
	robot.router.post '/slash/switch/register', (req, res) ->
		return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY
		if req.body.challenge?
			# Verify
			challenge = req.body.challenge
			return res.json challenge: challenge

		robot.logger.debug "Call /monitor-switch-register command."
		monitorList = robot.brain.get('MONITOR_SWITCH_CHANNEL') or {}

		payload = req.body
		flag = payload.text == 'true'
		monitorList[payload.channel_id] = flag
		robot.brain.set 'MONITOR_SWITCH_CHANNEL', monitorList
		res.send 'Update monitor switch status in this channel: ' + flag

	robot.router.post '/slash/switch/list', (req, res) ->
		return unless req.body.token == process.env.HUBOT_SLACK_TOKEN_VERIFY
		if req.body.challenge?
			# Verify
			challenge = req.body.challenge
			return res.json challenge: challenge

		robot.logger.debug "Call /monitor-switch-list command."
		monitorList = robot.brain.get('MONITOR_SWITCH_CHANNEL') or {}

		payload = req.body
		channelFlag = monitorList[payload.channel_id] or false
		res.send channelFlag

	new CronJob '0 */1 * * * *', () ->
		robot.logger.debug "Chromy init"
		flag = robot.brain.get('NIN_STORE') * 1 or 0
		attachment = {}
		if flag == 0
			str = "マイニンテンドーストアにSwitch入荷したよ!!\n" + MY_NINTENDO_STORE
			attachment = {
				text: str
				fallback: str
				color: 'good'
				mrkdwn_in: ['text']
				}
		else
			str = "売り切れた..."
			attachment = {
				text: str
				fallback: str
				color: 'danger'
				mrkdwn_in: ['text']
				}

		chromy = new Chromy
		chromy.chain()
			.goto MY_NINTENDO_STORE
			.evaluate () ->
				return document.querySelector('div#HAC_S_KAYAA > p.stock').textContent
			.result (r) ->
				if r != 'SOLD OUT' && r != ""
					if flag == 0
						notifyList = robot.brain.get('MONITOR_SWITCH_CHANNEL') ? {}
						Object.keys(notifyList).forEach (key) ->
							val = @[key]
							if val
								robot.messageRoom key, {attachments: [attachment]}
						, notifyList
					robot.brain.set 'NIN_STORE', 1
				else
					if flag == 1
						notifyList = robot.brain.get('MONITOR_SWITCH_CHANNEL') ? {}
						Object.keys(notifyList).forEach (key) ->
							val = @[key]
							if val
								robot.messageRoom key, {attachments: [attachment]}
						, notifyList
					robot.brain.set 'NIN_STORE', 0
			.end()
			.then () ->
				robot.logger.debug "Finish chromy"
				chromy.close()
			.catch (e) ->
				robot.logger.debug "Error chromy"
				robot.logger.debug e
				chromy.close()

	, null, true, "Asia/Tokyo"
