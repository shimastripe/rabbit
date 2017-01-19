# 連続して同じエラーをまとめて表示、ファイルをまたぐ場合はわけて表示
CheckStyleExecutor = require './checkstyle'
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

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .map (obj) => @convertForm obj
    .reduce ((acc, x, idx, source) ->
      if acc.length is 0
        acc.push x
        return acc

      last = acc[acc.length - 1]
      if last.file is x.file and last.detail is x.detail
        last.lineno += ",#{x.lineno}"
        acc[acc.length - 1] = last
      else
        acc.push x
      return acc
    ), []
    .flatMap (x) -> Rx.Observable.from x
    .reduce ((acc, x, idx, source) ->
      msg = "[#{x.signal}]\n#{x.file.split("tmp/repository/")[1]}:#{x.lineno} [#{x.type}]\n#{x.detail}"
      acc += "\n\n#{msg}"
    ), "[result]"
