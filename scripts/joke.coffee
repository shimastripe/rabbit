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

  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName

  robot.respond /ECHO (.*)$/i, (msg) ->
    console.log(msg.envelope.user.name)
    msg.send msg.match[1]

  robot.respond /TIME$/i, (msg) ->
    msg.send "Server time is: #{new Date()}"

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

  # baka
  robot.hear /.*/g, (res)->
    return if Math.random() < 0.98
    res.send res.random [
      "駄目だよ、カメが休んじゃ"
      "暇そうで羨ましい"
      "それが何の役に立つんだ？"
      "そんなこともわからないの..."
      "また何かくだらないことを始めたな"
      "人間でしょ？考えて！"
      "twitterをやめてほしい"
      "久しぶりにキレちまったよ..."
      "その時間、もっと他のことに使えなかったの？"
      "ガタガタいってると人参食わせるぞ"
      "鶴は恩返しするのになあ"
      "お前の背中もカチカチ燃やしてやろうか？"
      "キツネですら手袋にお金払うよ"
      "生きよ、そなたは美しい"
      "気持ち悪いオタクが全員死んで欲しい"
      "うるさい"
      "どうして動かなくなっちゃったの...？"
      "やだよ...こんなのってないよ..."
      "助けて..."
      "君はすごいよ"
      "承認欲求高すぎw"
      "囲われてーーーー"
      "助けてーーーーー！"
      "いやはや...やっぱ俺ってすごいわ。"
      "えっどういうこと？"
      "調子はどうでちゅか〜？"
      "僕が光なら君は闇だね"
      "もうちょっと身のある話をして"
      "暇な人間の相手をするか"
      "それは君の甘え"
      "愛してるよ"
      "チョロいな〜"
      "いつでも世界は回るし君は中心じゃない"
      "剣を持てばお前を抱き締められない 剣を持たなければお前を守れない - BLEACH 5「LIGHT ARM OF THE GIANT」"
      "研いだ爪は使わないと"
      "それ、欧米じゃ通用しないよ"
      "日本人の悪い癖だね〜"
      "まとめるとそういうことだね"
      "それ俺も考えたことあるわー"
      "コンテキスト考えて発言してよ"
      "5年前ならそうだったかもね"
      "やっぱ俺マイノリティかぁw"
      "君をアサインするよ☆"
      "人脈！人脈ゥ！"
      "もっとフレキシブルに動けないかなあ"
      "LGTM"
      "それ、採用！"
      "リスクマネジメントって言葉わかる？"
      "L.A.では当たり前だよ"
      "フラットじゃないなあ"
      "理解、してもらえたかな？"
      "ま、いいんじゃない。君がそう思うのなら"
      "それ人脈広がる？"
      "ビジネスモデルで喩えてもらえる？"
      "お、意識高いねえ"
      "あー、ちょっと難しかったかな？"
      "ふぅん、じゃあ起業する？"
      "ニアリーイコール......だね(ちょっと違うけどだいたい合ってます)"
      "何が目的？"
      "忙しいアピールはダサいよ"
      "頑張ってるキミを見てると僕も頑張れる"
    ]
