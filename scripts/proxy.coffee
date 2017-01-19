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
  FalsePositiveWarning = mongoose.model 'FalsePositiveWarning'

  robot.hear /ignore (\S*) (\S*)$/, (res) ->
    file = res.match[1]
    lineno = parseInt res.match[2].split(':')[0]
    sub_lineno = parseInt res.match[2].split(':')[1] or 0

    options =
      cwd: localPath
      maxBuffer: 1024 * 500

    exec "git blame -f -s -n -M -C -L #{lineno},+1 #{file.split('tmp/repository/')[1]}", options, (err, stdout, stderr)->
      console.error err if err
      console.error stderr if stderr

      d = stdout.split ' ', 4

      Checkstyle.find {file: file, lineno: lineno, sub_lineno: sub_lineno}
      .then (docs) ->
        return res.send "`#{file} #{lineno}` is not warned" if docs.length is 0

        fpw =
          commit: d[0]
          file: d[1]
          lineno: parseInt(d[2], 10)
          detail: docs[0].detail

        FalsePositiveWarning.update {file: fpw.file, lineno: fpw.lineno}, fpw, {upsert: true}, (err) ->
          return console.log err if err
          res.send "register `#{file} #{lineno}` in false-positive alert list"

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
