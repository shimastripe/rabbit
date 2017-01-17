Rx = require 'rx'

module.exports = class AnalysisExecutor
  constructor: (@name, @options={})->
    @url = "/tool/#{@name}"

  exec: (cb)->
    http.post @url, @options, (req, res)=>
    @observe req.body, cb

  toIterable: (raw)-> raw

  parse: (line)-> line

  process: (observable)-> observable

  observe: (raw, cb)->
    data = @toIterable raw
    @process(Rx.Observable.from(data).map (raw) => @parse raw)
      .subscribe (msg)-> cb msg
