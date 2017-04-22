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
    for line in raw.split '\n'
      obj = @parse line
      if obj is null 
        continue      
      
      @saveCurrentWarning obj
      
      if not gitBlameList.hasOwnProperty obj.file
        console.log obj.file
        out = @execGitBlame obj.file
        
      
      
      


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

  parseGitBlame: (blames) ->
    # 1ファイルあたりのblameを分割する処理を書く

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
