{EventEmitter} = require 'events'
Rx = require 'rx'

module.exports = (robot) ->
	webhook2observable = do ->
		ev = new EventEmitter
		robot.router.post '/webhook/github', (req, res) ->
			ev.emit 'webhook', req, res
			res.send 'OK'
	return -> Rx.Observable.fromEvent(ev)
