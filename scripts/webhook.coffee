{EventEmitter} = require 'events'
Rx = require 'rx'

module.exports = class Webhook2Observable
	constructor: (robot, options={})->
		robot.logger.info "github-stream"
		ev = new EventEmitter
		@source = do ->
			robot.router.post '/webhook/github', (req, res) ->
				ev.emit 'webhook', req
				res.send 'OK'
			Rx.Observable.fromEvent(ev, 'webhook')

	simpleHook: ()->
		return @source
