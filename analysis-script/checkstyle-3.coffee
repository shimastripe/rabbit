# 版間追跡手法
CheckStyleExecutor = require './checkstyle'
Rx = require 'rx'
mongoose = require '../lib/mongoose'
path = require "path"
exec = require('child-process-promise').exec

localPath = path.resolve "tmp/repository"

Checkstyle = mongoose.model 'Checkstyle'
FalsePositiveWarning = mongoose.model 'FalsePositiveWarning'

module.exports = class CheckStyleExecutor3 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-3', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .groupBy (x) -> x.file
    .concatMap (grouped) ->
      options =
        cwd: localPath
        maxBuffer: 1024 * 500
      exec "git blame -f -s -n -M -C #{grouped.key}", options
      .then (res) ->
        console.error stderr if res.stderr
        [grouped.key, res.stdout]
      .catch (err) -> console.error err
    .concatMap (x)->
      groupKey = x[0]
      stdout = x[1]
      Rx.Observable.from stdout.split '\n'
      .map (y) ->
        regexp = new RegExp /(\S*)\s+(\S*)\s+(\d+)\s+(.*)/, 'i'
        d = y.match regexp
        return null unless d
        {commit: d[1], file: d[2], lineno: d[3]}
      .filter (line) -> line
      .reduce (acc, x) ->
        acc.push x
        acc
      , []
      .map (array) ->
        [groupKey, array]
    .reduce (acc, x)->
      acc[x[0]] = x[1]
      acc
    , {}
    .concatMap (blameList) ->
      observable
      .filter (line) -> line unless null
      .map (warning) ->
        blame = blameList[warning.file][warning.lineno - 1]
        [warning, {commit: blame.commit, lineno: blame.lineno, file: blame.file, detail: warning.detail}]
    .concatMap (z) ->
      warning = z[0]
      query = z[1]
      FalsePositiveWarning.find query
      .then (docs) -> [warning, docs.length is 0]
    .filter (x) -> x[1]
    .reduce ((acc, x, idx, source) ->
      num = "#{x[0].lineno}"
      num += ":#{x[0].sub_lineno}" if x[0].sub_lineno isnt 0
      msg = "[#{x[0].signal}]\n#{x[0].file}:#{num} [#{x[0].type}]\n#{x[0].detail}"
      acc += "\n\n#{msg}"
    ), "[result]"
