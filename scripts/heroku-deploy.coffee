Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  robot.router.post '/heroku/deploy-done', (req, res) ->
    return unless Slack.isSlackAdapter robot
    slack = new Slack robot
    res.send 'OK'
