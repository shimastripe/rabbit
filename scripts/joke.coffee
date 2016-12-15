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

url = require 'url'
path = require 'path'

module.exports = (robot) ->
  robot.hear /助け/i, (res) ->
    res.send "助けは来ないよ"
  robot.hear /辛/i, (res) ->
    res.send "#{url.resolve(process.env.HUBOT_HEROKU_URL, path.join('image', 'rabbit.png'))}"
