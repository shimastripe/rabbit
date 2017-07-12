Webhook2Observable = require './webhook'

module.exports = (robot) ->
	webhook2observable = Webhook2Observable robot
	webhook2observable().subscribe (req ,res) ->
		console.log req.body
