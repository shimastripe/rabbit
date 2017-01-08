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

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.join(__dirname, "tmp")

module.exports = (robot) ->

  git = new Git()

  robot.hear /pull$/i, (res) ->
    res.send "pull..."
    git.pullRepo(CLONE_URL, localPath, "origin/master")
    .then ->
      res.send "[finished] git pull origin master"
    .catch (err) ->
      res.send "#{err}"

  robot.hear /tig$|tig (\d*)$/i, (res) ->
    res.send "tig..."
    git.commitHistory(CLONE_URL, localPath)
    .then (history) ->
      count = 0
      num = parseInt(res.match[1], 10) or 1

      history.on "commit", (commit)->
        if (++count > num)
          return;
        res.send """
        commit #{commit.sha()}
        Author: #{commit.author().name()} <#{commit.author().email()}>
        Date: #{commit.date()}
            #{commit.message()}
        """

      history.start()

  robot.hear /checkstyle (.*)$/, (res) ->
    options =
      cwd: localPath

    exec 'java -jar ../checkstyle-6.19-all.jar -c /google_checks.xml src/main/java', options,(err, stdout, stderr)->
      console.log err if err
      res.send "#{stdout}"
      res.send "#{stderr}"

  robot.hear /blame$/i, (res) ->
    res.send "blame..."
    git.cloneOrOpenRepo(CLONE_URL, localPath)
    .then (repo) ->
      nodeGit.Blame.file(repo, ".gitignore")
      .then (blame) ->
        console.log blame.getHunkByLine(1).finalCommitId()
        console.log blame.getHunkCount()
        JSON.stringify(blame)
      .catch (err) ->
        console.log "error!! #{err}"

      exec 'git blame -s -n -M -C package.json', (err, stdout, stderr)->
        console.log "#{stdout}"
