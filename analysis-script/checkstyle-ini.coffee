# 連続して同じエラーをまとめて表示、ファイルをまたぐ場合はわけて表示
CheckStyleExecutor = require './adapter/checkstyle'
Rx = require 'rx'

module.exports = class CheckStyleExecutorIni extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-ini', @options
