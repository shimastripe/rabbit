Chromy = require 'chromy'
SlackBot = require.main.require 'hubot-slack/src/bot'
{CronJob} = require 'cron'

MY_NINTENDO_STORE = 'https://store.nintendo.co.jp/customize.html'

module.exports = (robot) ->
	new CronJob '0 */1 * * * *', () ->
		console.log "Chromy init"
		str = "マイニンテンドーストアにSwitch入荷したよ!!\n" + MY_NINTENDO_STORE
		attachments = [
			text: str,
			fallback: str,
			color: 'good'
		]
		chromy = new Chromy
		chromy.chain()
			.goto MY_NINTENDO_STORE
			.evaluate () ->
				return document.querySelector('div#HAC_S_KAYAA > p.stock').textContent
			.result (r) ->
				if r != 'SOLD OUT' && r != ""
					if robot.adapter instanceof SlackBot
						robot.adapter.client.web.chat.postMessage process.env.HUBOT_SLACK_M1_ROOM, "", {as_user: true, unfurl_links: false, attachments: attachments }
					else robot.messageRoom process.env.HUBOT_SLACK_M1_ROOM, str
			.end()
			.then () ->
				console.log "Finish"
				chromy.close()
			.catch (e) ->
				console.log e
				chromy.close()

	, null, true, "Asia/Tokyo"
