# 1度出たエラーは返さない (file, lineno, detail一致判断)
CheckStyleExecutor = require './adapter/checkstyle'
mongoose = require '../lib/mongoose'

Checkstyle = mongoose.model 'Checkstyle'

module.exports = class CheckStyleExecutor1 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-1', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .concatMap (warning) => @isRegistered warning
    .filter (x) -> x[1]
    .do (pair) => @register pair[0]
    .reduce ((acc, x) => acc += "\n\n#{@formatMessage x[0]}"), "[result]"

  isRegistered: (warning) ->
    Checkstyle.find {file: warning.file, lineno: warning.lineno, sub_lineno: warning.sub_lineno, detail: warning.detail}
    .then (docs) -> return [warning, docs.length is 0]

  register: (warning) ->
    Checkstyle.update {file: warning.file, lineno: warning.lineno, sub_lineno: warning.sub_lineno, detail: warning.detail}, warning, {upsert: true}
    .catch (err) -> console.error err

  formatMessage: (msg) ->
    num = "#{msg.lineno}"
    num += ":#{msg.sub_lineno}" if msg.sub_lineno isnt 0
    "[#{msg.signal}]\n#{msg.file}:#{num} [#{msg.type}]\n#{msg.detail}"
