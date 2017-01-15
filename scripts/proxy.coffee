# Description:
#   git blame -s -n -M -C hoge.c
#
# Dependencies:
#   None
#
# Commands:
#   pull - git pull origin master
#   tig <count> - show git history
#
# Author:
#   Go Takagi

path = require "path"
nodeGit = require "nodegit"
Git = require "../lib/git"
exec = require('child_process').exec
Rx = require 'rx'
mongoose = require 'mongoose'
mongoose.Promise = global.Promise

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.resolve "tmp/repository"
checkstylePath = path.resolve "checkstyle/checkstyle-7.4-all.jar"

parseMessage = (line) ->
  obj = {}
  regexp = new RegExp /\[(WARN|ERROR)\] (.*):(\d+): (.*) \[(.*)\]/, 'i'
  match = line.match regexp
  if match is null
    return null
  obj =
    signal: match[1]
    file: match[2].split("tmp/")[1]
    lineno: parseInt(match[3], 10)
    detail: match[4]
    type: match[5]

module.exports = (robot) ->

  git = new Git()
  Checkstyle = mongoose.model 'Checkstyle', {signal: String, file: String, lineno: Number, detail: String, type: String}
  mongoose.connect(process.env.MONGODB_URI)

  robot.hear /pull$/i, (res) ->
    res.send "pull..."
    git.pullRepo CLONE_URL, localPath, "origin/master"
    .then ->
      res.send "[finished] git pull origin master"
    .catch (err) -> res.send "#{err}"

  robot.hear /tig$|tig (\d*)$/i, (res) ->
    res.send "tig..."
    git.commitHistory CLONE_URL, localPath
    .then (history) ->
      count = 0
      num = parseInt(res.match[1], 10) or 1

      history.on "commit", (commit)->
        if ++count > num
          return;
        res.send """
        commit #{commit.sha()}
        Author: #{commit.author().name()} <#{commit.author().email()}>
        Date: #{commit.date()}
            #{commit.message()}
        """

      history.start()

  robot.hear /checkstyle (.*)$/, (res) ->
    git.cloneOrOpenRepo CLONE_URL, localPath, "origin/master"
    .then ->
      options =
        cwd: localPath
        maxBuffer: 1024 * 500

      exec 'java -jar ' + checkstylePath + ' -c /google_checks.xml src/main/java', options, (err, stdout, stderr) ->
        console.log err if err
        return res.send stderr if stderr
        source = Rx.Observable.from stdout.split '\n'

        source
        .map (line) -> parseMessage line
        .filter (line) -> line unless null
        .take parseInt(res.match[1], 10) or 1
        .do (x, err) ->
          # save database
          Checkstyle.update {file: x.file, lineno: x.lineno}, x, {upsert: true}, (err) ->
            console.log err if err
        .reduce ((acc, x, idx, source) ->
          msg = "[#{x.signal}]\n#{x.file}:#{x.lineno} [#{x.type}]\n#{x.detail}"
          acc += "\n\n#{msg}"
        ), "[result]"
        .subscribe (x) -> res.send "#{x}"
    .catch (err) -> res.send "#{err}"

  # 1度出たエラーは返さない (file, lineno, detail一致判断)
  robot.hear /checkstyle_1 (.*)$/, (res) ->
    git.cloneOrOpenRepo CLONE_URL, localPath, "origin/master"
    .then ->
      options =
        cwd: localPath
        maxBuffer: 1024 * 500

      exec 'java -jar ' + checkstylePath + ' -c /google_checks.xml src/main/java', options, (err, stdout, stderr) ->
        console.log err if err
        return res.send stderr if stderr
        source = Rx.Observable.from stdout.split '\n'

        source
        .map (line) -> parseMessage line
        .filter (line) -> line unless null
        .take parseInt(res.match[1], 10) or 1
        .concatMap (x) ->
          # check database
          Checkstyle.find {file: x.file, lineno: x.lineno, detail: x.detail}
          .then (docs) -> return [x, docs.length is 0]
        .filter (x) -> x[1]
        .do (x, err) ->
          # save database
          Checkstyle.update {file: x[0].file, lineno: x[0].lineno}, x[0], {upsert: true}, (err) ->
            return console.log err if err
        .reduce ((acc, x, idx, source) ->
          msg = "[#{x[0].signal}]\n#{x[0].file}:#{x[0].lineno} [#{x[0].type}]\n#{x[0].detail}"
          acc += "\n\n#{msg}"
        ), "[result]"
        .subscribe (x) -> res.send "#{x}"
    .catch (err) -> res.send "#{err}"

  robot.hear /get all$/i, (res) ->
    Checkstyle.find {}, (err, docs) ->
      for document in docs
        res.send "#{document}"

  robot.hear /delete all$/i, (res) ->
    Checkstyle.remove {}, (err) ->
      return console.log err if err
      res.send "Checkstyle collection all removed!"

  robot.hear /blame$/i, (res) ->
    res.send "blame..."
    git.cloneOrOpenRepo CLONE_URL, localPath
    .then (repo) ->
      nodeGit.Blame.file(repo, ".gitignore")
      .then (blame) ->
        console.log blame.getHunkByLine(1).finalCommitId()
        console.log blame.getHunkCount()
        JSON.stringify blame
      .catch (err) ->
        console.log "error!! #{err}"

      exec 'git blame -s -n -M -C package.json', (err, stdout, stderr)->
        console.log "#{stdout}"
