{EventEmitter} = require 'events'
Rx = require 'rx'

module.exports = (robot) ->
	ev = new EventEmitter
	webhook2observable = do ->
		robot.router.post '/webhook/github', (req, res) ->
			ev.emit 'webhook', req, res
			res.send 'OK'
	return -> Rx.Observable.fromEvent(ev, 'webhook')
