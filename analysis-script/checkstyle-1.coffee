# 1度出たエラーは返さない (file, lineno, detail一致判断)
CheckStyleExecutor = require './checkstyle'
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
    .concatMap (x) ->
      # check database
      Checkstyle.find {file: x.file, lineno: x.lineno, sub_lineno: x.sub_lineno, detail: x.detail}
      .then (docs) -> return [x, docs.length is 0]
    .filter (x) -> x[1]
    .do (x, err) ->
      # save database
      Checkstyle.update {file: x[0].file, lineno: x[0].lineno, sub_lineno: x[0].sub_lineno, detail: x[0].detail}, x[0], {upsert: true}, (err) ->
        return console.log err if err
    .reduce ((acc, x, idx, source) ->
      num = "#{x[0].lineno}"
      num += ":#{x[0].sub_lineno}" if x[0].sub_lineno isnt 0
      msg = "[#{x[0].signal}]\n#{x[0].file}:#{num} [#{x[0].type}]\n#{x[0].detail}"
      acc += "\n\n#{msg}"
    ), "[result]"
