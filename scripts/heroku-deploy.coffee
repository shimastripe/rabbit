Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  robot.router.post '/heroku/deploy-done', (req, res) ->
    res.send 'OK'
