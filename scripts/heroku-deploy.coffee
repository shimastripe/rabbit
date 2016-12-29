Slack = require 'hubot-slack-enhance'

module.exports = (robot) ->
  console.log(robot.adapter)

  robot.router.post '/heroku/deploy-done', (req, res) ->
    res.send 'OK'
