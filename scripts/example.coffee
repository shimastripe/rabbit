# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   secret = req.body.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'

  # robot.respond /test/, (res) ->
  #   room = res.envelope.room
  #   timestamp = new Date/1000|0
  #
  #   # https://api.slack.com/docs/message-attachments
  #   attachments = [
  #     {
  #       fallback: 'デプロイしたよ',
  #       color: 'good',
  #       pretext: 'デプロイしたよ',
  #       fields: [
  #         {
  #           title: 'Command',
  #           value: 'cap staging deploy',
  #           short: false
  #         }
  #         {
  #           title: 'Stage',
  #           value: 'staging',
  #           short: true
  #         },
  #         {
  #           title: 'Status',
  #           value: '0',
  #           short: true
  #         },
  #         {
  #           title: 'Output',
  #           value: '12323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323123231232312323',
  #           short: false
  #         }
  #       ],
  #       footer: 'hubot',
  #       footer_icon: 'https://hubot.github.com/assets/images/layout/hubot-avatar@2x.png',
  #       ts: timestamp
  #     }
  #   ]
  #
  #   options = { as_user: true, link_names: 1, attachments: attachments }
  #
  #   client = robot.adapter.client
  #   client.web.chat.postMessage(room, '', options)
  #
  # robot.hear /hoge/i, (res) ->
  #   robot.adapter.client.web.api.test() # call `api.test` endpoint
  #
  #   attachments = [
  #     {
  #       text: "Choose a game to play",
  #       fallback: "You are unable to choose a game",
  #       callback_id: "wopr_game",
  #       color: "#3AA3E3",
  #       attachment_type: "default",
  #       actions: [
  #         {
  #           name: "chess",
  #           text: "Chess",
  #           type: "button",
  #           value: "chess"
  #         },
  #         {
  #           name: "maze",
  #           text: "Falken's Maze",
  #           type: "button",
  #           value: "maze"
  #         },
  #         {
  #           name: "war",
  #           text: "Thermonuclear War",
  #           style: "danger",
  #           type: "button",
  #           value: "war",
  #           confirm: {
  #             title: "Are you sure?",
  #             text: "Wouldn't you prefer a good game of chess?",
  #             ok_text: "Yes",
  #             dismiss_text: "No"
  #           }
  #         }
  #       ]
  #     }
  #   ]
  #
  #   # There are better ways to post messages of course
  #   # Notice the _required_ arguments `channel` and `text`, and the _optional_ arguments `as_user`, and `unfurl_links`
  #   robot.adapter.client.web.chat.postMessage(res.envelope.room, "This is a message!", {as_user: true, unfurl_links: false, attachments: attachments })
