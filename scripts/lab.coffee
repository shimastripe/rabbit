# Description:
#   joke commands
#
# Dependencies:
#   None
#
# Commands:
#   PING - PONG
#   ADAPTER - adapterName
#   NAME - robotName
#   ECHO - echo msg
#   助け - 助けは来ないよ
#   辛 - 駄目だよカメが休んじゃ
#   今日 - 華金かどうかチェックする
#
# Author:
#   Go Takagi

ADDRESS = process.env.HEROKU_URL or 'http://localhost:8080'

urljoin = require('url-join')
util = require('../lib/util')

module.exports = (robot) ->

  robot.hear /助け/i, (res) ->
    res.send "助けは来ないよ"

  robot.hear /終わり/i, (res) ->
    res.send "終わったね"

  robot.hear /辛/i, (res) ->
    timestamp = '?' + (new Date()).toISOString().replace(/[^0-9]/g, "")
    res.send urljoin(ADDRESS, 'image', 'rabbit.png', timestamp)

  robot.hear /^今日$/i, (res) ->
    dayOfWeek = res.random ['月', '火', '水', '木', '金', '金', '金']
    message = "今日は#{dayOfWeek}曜日！"
    if dayOfWeek == '金'
      message += '\n華金だね〜！'
    res.send message
