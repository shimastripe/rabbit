# 連続して同じエラーをまとめて表示、ファイルをまたぐ場合はわけて表示
CheckStyleExecutor = require './adapter/checkstyle'
Rx = require 'rx'

module.exports = class CheckStyleExecutor2 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-2', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  formatMessage: (msg) -> "[#{msg.signal}]\n#{msg.file}:#{msg.lineno} [#{msg.type}]\n#{msg.detail}"

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .reduce ((acc, x) => acc += "\n\n#{@formatMessage x}"), "[result]"
