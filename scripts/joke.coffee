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


  robot.respond /test/, (res) ->
    room = res.envelope.room
    timestamp = new Date/1000|0

    # https://api.slack.com/docs/message-attachments
    attachments = [
      {
        fallback: 'デプロイしたよ',
        color: 'good',
        pretext: 'デプロイしたよ',
        fields: [
          {
            title: 'Command',
            value: 'cap staging deploy',
            short: false
          }
          {
            title: 'Stage',
            value: 'staging',
            short: true
          },
          {
            title: 'Status',
            value: '0',
            short: true
          },
          {
            title: 'Output',
            value: '12323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323',
            short: false
          }
        ],
        footer: 'hubot',
        footer_icon: 'https://hubot.github.com/assets/images/layout/hubot-avatar@2x.png',
        ts: timestamp
      }
    ]

    options = { as_user: true, link_names: 1, attachments: attachments }

    client = robot.adapter.client
    client.web.chat.postMessage(room, '', options)

  robot.hear /hoge/i, (res) ->
    robot.adapter.client.web.api.test() # call `api.test` endpoint

    attachments = [
      {
        text: "Choose a game to play",
        fallback: "You are unable to choose a game",
        callback_id: "wopr_game",
        color: "#3AA3E3",
        attachment_type: "default",
        actions: [
          {
            name: "chess",
            text: "Chess",
            type: "button",
            value: "chess"
          },
          {
            name: "maze",
            text: "Falken's Maze",
            type: "button",
            value: "maze"
          },
          {
            name: "war",
            text: "Thermonuclear War",
            style: "danger",
            type: "button",
            value: "war",
            confirm: {
              title: "Are you sure?",
              text: "Wouldn't you prefer a good game of chess?",
              ok_text: "Yes",
              dismiss_text: "No"
            }
          }
        ]
      }
    ]

    # There are better ways to post messages of course
    # Notice the _required_ arguments `channel` and `text`, and the _optional_ arguments `as_user`, and `unfurl_links`
    robot.adapter.client.web.chat.postMessage(res.envelope.room, "This is a message!", {as_user: false, unfurl_links: false, attachments: attachments })
