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

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.resolve "scripts/tmp"

# [WARN] /Users/gtakagi/sandbox/gtakagi-chatbot/scripts/tmp/src/main/java/WifiWatcher.java:91: インデント階層 4 の method def rcurly が正しいインデント 2 にありません [Indentation]
parseMessage = (line) ->
  obj = {}
  regexp = new RegExp /\[(WARN|ERROR)\] (.*): (.*) \[(.*)\]/, 'i'
  match = line.match regexp
  if match is null
    return null
  obj =
    signal: match[1]
    name: match[2].split("tmp/")[1]
    detail: match[3]
    type: match[4]

module.exports = (robot) ->

  git = new Git()

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

      exec 'java -jar ../checkstyle-6.19-all.jar -c /google_checks.xml src/main/java', options, (err, stdout, stderr) ->
        console.log err if err
        res.send stderr if stderr
        source = Rx.Observable.from stdout.split '\n'

        source
        .map (line) -> parseMessage line
        .filter (line) -> line unless null
        .take res.match[1] or 0
        .subscribe (x) -> res.send "#{x.name} #{x.detail}"
    .catch (err) -> res.send "#{err}"

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
