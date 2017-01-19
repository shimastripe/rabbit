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
mongoose = require '../lib/mongoose'

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.resolve "tmp/repository"

module.exports = (robot) ->

  git = new Git()
  Checkstyle = mongoose.model 'Checkstyle'

  robot.hear /ignore (\S*) (\S*)$/, (res) ->
    fileName = res.match[1]
    lineno = res.match[2]
    res.send "register `#{fileName} #{lineno}` in false-positive alert list"

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
