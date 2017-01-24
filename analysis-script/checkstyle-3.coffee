# 版間追跡手法
CheckStyleExecutor = require './adapter/checkstyle'
Rx = require 'rx'
mongoose = require '../lib/mongoose'
path = require "path"
exec = require('child-process-promise').exec

localPath = path.resolve "tmp/repository"

Checkstyle = mongoose.model 'Checkstyle'
FalsePositiveWarning = mongoose.model 'FalsePositiveWarning'
Rx.Observable::promiseWait = (func) ->
  this.concatMap (x) -> func x

module.exports = class CheckStyleExecutor3 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-3', @options

  exec: (cb) ->
    Checkstyle.remove {}
    .then => super cb
    .catch (err) -> cb "#{err}"

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .promiseWait (warning) => @saveCurrentWarning warning
    .groupBy (x) -> x.file
    .promiseWait (grouped) => @execGitBlame grouped.key
    .concatMap (pair) => @parseGitBlame pair[0], pair[1]
    .reduce ((acc, x) => @aggregate acc, x[0], x[1]), {}
    .concatMap (blameList) => @join observable, blameList
    .promiseWait (pair) => @isFalsePositiveWarning pair[0], pair[1]
    .filter (x) -> x[1]
    .reduce ((acc, x) => acc += "\n\n#{@formatMessage x[0]}"), "[result]"

  saveCurrentWarning: (warning) ->
    Checkstyle.update {file: warning.file, lineno: warning.lineno, sub_lineno: warning.sub_lineno, detail: warning.detail}, warning, {upsert: true}
    .then -> return warning
    .catch (err) -> console.log err

  execGitBlame: (filename) ->
    options =
      cwd: localPath
      maxBuffer: 1024 * 500
    exec "git blame -f -s -n -M -C #{filename}", options
    .then (res) ->
      console.error stderr if res.stder
      [filename, res.stdout]
    .catch (err) -> console.error err

  parseGitBlame: (groupKey, stdout) ->
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
    .map (arr) ->
      [groupKey, arr]

  aggregate: (acc, filename, blame) ->
    acc[filename] = blame
    acc

  join: (observable, blameList) ->
    observable
    .filter (line) -> line unless null
    .map (warning) ->
      blame = blameList[warning.file][warning.lineno - 1]
      [warning, {commit: blame.commit, lineno: blame.lineno, file: blame.file, detail: warning.detail}]

  isFalsePositiveWarning: (warning, query) ->
    FalsePositiveWarning.find query
    .then (docs) -> [warning, docs.length is 0]

  formatMessage: (msg) ->
    num = "#{msg.lineno}"
    num += ":#{msg.sub_lineno}" if msg.sub_lineno isnt 0
    "[#{msg.signal}]\n#{msg.file}:#{num} [#{msg.type}]\n#{msg.detail}"
