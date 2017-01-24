# 連続して同じエラーをまとめて表示、ファイルをまたぐ場合はわけて表示
CheckStyleExecutor = require './adapter/checkstyle'
Rx = require 'rx'

module.exports = class CheckStyleExecutor2 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-2', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  convertForm: (obj) ->
    if obj.sub_lineno is 0
      obj.lineno = "#{obj.lineno}"
    else
      obj.lineno = "#{obj.lineno}:#{obj.sub_lineno}"
    delete obj.sub_lineno
    return obj

  join: (acc, warning) ->
    if acc.length is 0
      acc.push warning
      return acc

    lastItem = acc[acc.length - 1]
    if lastItem.file is warning.file and lastItem.detail is warning.detail
      lastItem.lineno += ",#{warning.lineno}"
      acc[acc.length - 1] = lastItem
    else
      acc.push warning
    return acc

  formatMessage: (msg) -> "[#{msg.signal}]\n#{msg.file}:#{msg.lineno} [#{msg.type}]\n#{msg.detail}"

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .map (obj) => @convertForm obj
    .reduce ((acc, x) => @join acc, x), []
    .flatMap (x) -> Rx.Observable.from x
    .reduce ((acc, x) => acc += "\n\n#{@formatMessage x}"), "[result]"
