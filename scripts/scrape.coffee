Chromy = require 'chromy'
SlackBot = require.main.require 'hubot-slack/src/bot'
{CronJob} = require 'cron'

MY_NINTENDO_STORE = 'https://store.nintendo.co.jp/customize.html'

module.exports = (robot) ->
	new CronJob '0 */1 * * * *', () ->
		console.log "Chromy init"
		flag = robot.brain.get('NIN_STORE') * 1 or 0
		str = ""
		color = ""
		if flag == 0
			str = "マイニンテンドーストアにSwitch入荷したよ!!\n" + MY_NINTENDO_STORE
			color = "good"
		else
			str = "売り切れた..."
			color = "danger"

		attachments = [
			text: str,
			fallback: str,
			color: color
		]

		chromy = new Chromy
		chromy.chain()
			.goto MY_NINTENDO_STORE
			.evaluate () ->
				return document.querySelector('div#HAC_S_KAYAA > p.stock').textContent
			.result (r) ->
				if r != 'SOLD OUT' && r != ""
					if flag == 0
						if robot.adapter instanceof SlackBot
							robot.adapter.client.web.chat.postMessage process.env.HUBOT_SLACK_M1_ROOM, "", {as_user: true, unfurl_links: false, attachments: attachments }
						else robot.messageRoom process.env.HUBOT_SLACK_M1_ROOM, str

					robot.brain.set 'NIN_STORE', 1
				else
					if flag == 1
						if robot.adapter instanceof SlackBot
							robot.adapter.client.web.chat.postMessage process.env.HUBOT_SLACK_M1_ROOM, "", {as_user: true, unfurl_links: false, attachments: attachments }
						else robot.messageRoom process.env.HUBOT_SLACK_M1_ROOM, str

					robot.brain.set 'NIN_STORE', 0
			.end()
			.then () ->
				console.log "Finish"
				chromy.close()
			.catch (e) ->
				console.log "Error"
				console.log e
				chromy.close()

	, null, true, "Asia/Tokyo"
