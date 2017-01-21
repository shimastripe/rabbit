# 版間追跡手法
CheckStyleExecutor = require './checkstyle'
Rx = require 'rx'
mongoose = require '../lib/mongoose'
path = require "path"
exec = require('child-process-promise').exec

localPath = path.resolve "tmp/repository"

Checkstyle = mongoose.model 'Checkstyle'
FalsePositiveWarning = mongoose.model 'FalsePositiveWarning'

execGitBlame = (filename)->
	new Promise (resolve)-> resolve gitBlameResult[filename]

module.exports = class CheckStyleExecutor3 extends CheckStyleExecutor
  constructor: (@options) ->
    super 'checkstyle-3', @options

  exec: (cb) -> super cb

  toIterable: (raw) -> super raw

  parse: (line) -> super line

  process: (observable) ->
    gitBlameResult = {}

    observable
    .filter (line) -> line unless null
    .concatMap (x) ->

      if not(x.file of gitBlameResult)
        options =
          cwd: localPath
          maxBuffer: 1024 * 500

        exec "git blame -f -s -n -M -C #{x.file}", options
        .then (res) ->
          console.error stderr if res.stderr

          Rx.Observable.from res.stdout.split '\n'
          .map (y) ->
            regexp = new RegExp /(\S*)\s+(\S*)\s+(\d+)\s+(.*)/, 'i'
            d = y.match regexp
            if d is null
              return null
            {commit: d[1], detail: x.detail}
          .filter (line) -> line unless null
          .reduce ((acc, x, idx, source) ->
            acc.push x
            acc
          ), []
          .subscribe (obj) ->
            gitBlameResult[x.file] = obj
        .catch (err) -> console.error err


        # FalsePositiveWarning.find {commit: d[0], file: d[1], lineno: d[2], detail: x.detail}
        # .then (docs) -> return [x, docs.length isnt 0]

      return [x, false]
    .filter (x) -> x[1]
    .reduce ((acc, x, idx, source) ->
      num = "#{x[0].lineno}"
      num += ":#{x[0].sub_lineno}" if x[0].sub_lineno isnt 0
      msg = "[#{x[0].signal}]\n#{x[0].file}:#{num} [#{x[0].type}]\n#{x[0].detail}"
      acc += "\n\n#{msg}"
    ), "[result]"
