# Description:
#   git blame -s -n -M -C hoge.c
#
# Dependencies:
#   None
#
# Commands:
#   pull - git pull origin master
#   tig - show git history
#
# Author:
#   Go Takagi

path = require "path"
nodeGit = require "nodegit"

GITHUB_TOKEN = process.env.GITHUB_TOKEN or ''
CLONE_URL = process.env.GITHUB_CLONE_URL or ''

localPath = path.join(__dirname, "tmp");
cloneOptions = {}

cloneOptions.fetchOpts = callbacks:
  certificateCheck: ->
    1
  credentials: ->
    nodeGit.Cred.userpassPlaintextNew GITHUB_TOKEN, 'x-oauth-basic'

cloneOrOpenRepo = (url, dir, option) ->
  nodeGit.Repository.open(dir).catch ->
    nodeGit.Clone(url, dir, option)

updateRepo = (url, dir, option) ->
  cloneOrOpenRepo(url, dir, option)
  .then (repo) -> repo.fetchAll()

pullRepo = (dir, branch) ->
  nodeGit.Repository.open(dir)
  .then (repo) -> repo.mergeBranches("master", branch)

module.exports = (robot) ->

  robot.hear /pull$/i, (res) ->
    res.send "pull..."
    updateRepo(CLONE_URL, localPath, cloneOptions)
    .then ->
      pullRepo(localPath, "origin/master")
    .then ->
      res.send "[finished] git pull origin master"

  robot.hear /tig$/i, (res) ->
    res.send "tig..."
    cloneOrOpenRepo(CLONE_URL, localPath)
    .then (repo) ->
      repo.getMasterCommit()
    .then (firstCommitOnMaster)->
      history = firstCommitOnMaster.history()
      count = 0

      history.on "commit", (commit)->
        if (++count >= 9)
          return;
        s = """
        commit #{commit.sha()}
        Author: #{commit.author().name()} \<#{commit.author().email()}\>
        Date: #{commit.date()}
            #{commit.message()}
        """
        res.send s
      history.start()
    .catch (err)->
      console.log "error!! #{err}"
    .done ()->
      console.log "done!"
