# Description:
#
#
# Dependencies:
#   None
#
# Commands:
#   助け - 助けは来ないよ
#   辛 - 駄目だよカメが休んじゃ
#   今日 - 華金かどうかチェックする
#
# Author:
#   Go Takagi

ADDRESS = process.env.HEROKU_URL or 'http://localhost:8080'

urljoin = require('url-join')

module.exports = (robot) ->
  # import util
  util = require('../lib/util')(robot)

  robot.hear /助け/i, (res) ->
    res.send "助けは来ないよ"
  robot.hear /辛/i, (res) ->
    timestamp = '?' + (new Date()).toISOString().replace(/[^0-9]/g, "")
    res.send urljoin(ADDRESS, 'image', 'rabbit.png', timestamp)
  robot.hear /^今日$/i, (res) ->
    dayOfWeek = res.random ['月', '火', '水', '木', '金', '金', '金']
    message = "今日は#{dayOfWeek}曜日！"
    if dayOfWeek == '金'
      message += '\n華金だね〜！'
    res.send message
  robot.hear /.*/g, (res)->
    return if Math.random() < 0.97
    res.send res.random [
      "駄目だよ、カメが休んじゃ"
      "暇そうで羨ましい"
      "それが何の役に立つんだ？"
      "そんなこともわからないの..."
      "また何かくだらないことを始めたな"
      "考えて！考えて！人間だったら考えて！"
      "twitterをやめてほしい"
      "久しぶりにキレちまったよ..."
      "その時間、もっと他のことに使えなかったの？"
      "ガタガタいってると人参食わせるぞ"
      "鶴でも恩返ししてくれるのになあ"
      "竜宮城言ってないで金払うなら助けてやるよ"
      "お前の背中もカチカチ燃やしてやろうか？"
      "キツネですら手袋買うのにお金払うのになあ"
      "生きよ、そなたは美しい"
      "気持ち悪いオタクが全員死んで欲しい"
    ]
  robot.hear /(.*)/g, (res)->
    console.log(res.match[2])
    console.log(res.match)
    util.say(res.match[2], "[deploy] done", {as_user: false, unfurl_links: false})
  # robot.router.post "/heroku/deploy-done", (req, res) ->
  #   util.say("@" + process.env.HUBOT_SLACK_BOTNAME, "[deploy] done - #{req.body.app}(#{req.body.release})", {as_user: false, unfurl_links: false})
