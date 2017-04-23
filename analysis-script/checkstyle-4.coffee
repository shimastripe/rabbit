# Rxを用いない版間追跡手法
CheckStyleExecutor = require './adapter/checkstyle'
mongoose = require '../lib/mongoose'
path = require "path"
exec = require('child-process-promise').exec

localPath = path.resolve "tmp/repository"

Checkstyle = mongoose.model 'Checkstyle'
FalsePositiveWarning = mongoose.model 'FalsePositiveWarning'

module.exports = class CheckStyleExecutor3 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle4', @options

  exec: (cb) ->
    Checkstyle.remove {}
    .then => super cb
    .catch (err) -> cb "#{err}"

  observe: (raw, cb)->
    gitBlameList = {}
    p = []
    blameFileList = []
    # blameが必要なfileListを取得
    for line in raw.split '\n'
      obj = @parse line
      if obj is null 
        continue
      blameFileList.push obj.file
      p.push(@saveCurrentWarning obj)

    Promise.all p
    .then =>
      p = []
      b = blameFileList.filter (x, i, self) => self.indexOf(x) is i

      for blameFile in b
        promise = @execGitBlame blameFile
        .then (res)=>
          [res[0], @parseGitBlame res[1]]
        p.push promise
      p
    .then (q)->
      Promise.all q
      .then (val)->
        val.reduce (acc, e)->
          [k, v] = e
          acc[k] = v
          acc
        , {}

  saveCurrentWarning: (warning) ->
    Checkstyle.update {file: warning.file, lineno: warning.lineno, sub_lineno: warning.sub_lineno, detail: warning.detail}, warning, {upsert: true}
    .then -> return warning
    .catch (err) -> console.log err

  execGitBlame: (filename) ->
    options =
      cwd: localPath
      maxBuffer: 1024 * 500
    exec "git blame -f -s -n -M -C #{filename}", options
    .then (res) =>
      console.error stderr if res.stder
      [filename, res.stdout]
    .catch (err) -> console.error err

  parseGitBlame: (blames) ->
    obj = []
    for b in blames.split '\n'
      regexp = new RegExp /(\S*)\s+(\S*)\s+(\d+)\s+(.*)/, 'i'
      d = b.match regexp
      if d
        obj.push {commit: d[1], file: d[2], lineno: d[3]}
    obj

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
