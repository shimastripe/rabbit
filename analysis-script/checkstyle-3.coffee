# 版間追跡手法
CheckStyleExecutor = require './checkstyle'
mongoose = require '../lib/mongoose'

Checkstyle = mongoose.model 'Checkstyle'

module.exports = class CheckStyleExecutor1 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-3', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  process: (observable) ->
    observable
    .filter (line) -> line unless null
