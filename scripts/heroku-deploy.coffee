Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot

  robot.router.post '/heroku/deploy-done', (req, res) ->
    res.send 'OK'
