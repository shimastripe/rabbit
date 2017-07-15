Chromy = require 'chromy'
SlackBot = require.main.require 'hubot-slack/src/bot'

MY_NINTENDO_STORE = 'https://store.nintendo.co.jp/customize.html'

module.exports = (robot) ->
	robot.hear /switch/, (res) ->
		str = "マイニンテンドーストアにSwitch入荷したよ!!\n" + MY_NINTENDO_STORE
		attachments = [
			text: str,
			fallback: str,
			color: 'good'
		]
		chromy = new Chromy
		chromy.chain()
			.goto MY_NINTENDO_STORE
			.evaluate () =>
				return document.querySelector('div#HAC_S_KAYAA > p.stock').textContent
			.result (r) =>
				if r == 'SOLD OUT' && r != ""
					if robot.adapter instanceof SlackBot
						robot.adapter.client.web.chat.postMessage res.envelope.room, "", {as_user: true, unfurl_links: false, attachments: attachments }
					else robot.messageRoom res.envelope.room, str
			.end()
			.then () => chromy.close()
		res.end
