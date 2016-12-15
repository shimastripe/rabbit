# Description:
#
#
# Dependencies:
#   None
#
# Commands:
#   助け - 助けは来ないよ
#   辛 - 駄目だよカメが休んじゃ
#
# Author:
#   Go Takagi

urljoin = require('url-join')
date = new Date()

module.exports = (robot) ->
  robot.hear /助け/i, (res) ->
    res.send "助けは来ないよ"
  robot.hear /辛/i, (res) ->
    res.send urljoin(process.env.HEROKU_URL, 'image', 'rabbit.png', '?', date.getTime().toString())
