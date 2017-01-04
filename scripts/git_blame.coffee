# Description:
#   git blame -s -n -M -C hoge.c
#
# Dependencies:
#   None
#
# Commands:
#   blame - git blame
#
# Author:
#   Go Takagi

path = require "path"
nodeGit = require "nodegit"

GITHUB_TOKEN = process.env.GITHUB_TOKEN or ''
CLONE_URL = process.env.GITHUB_CLONE_URL or ''

localPath = path.join(__dirname, "tmp");
cloneOptions = {}

errorAndAttemptOpen = ->
  nodeGit.Repository.open localPath

cloneOptions.fetchOpts = callbacks:
  certificateCheck: ->
    1
  credentials: ->
    nodeGit.Cred.userpassPlaintextNew GITHUB_TOKEN, 'x-oauth-basic'

module.exports = (robot) ->

  robot.hear /blame$/i, (msg) ->
    msg.send "start!"

    cloneRepo = nodeGit.Clone(CLONE_URL, localPath, cloneOptions)

    cloneRepo.catch(errorAndAttemptOpen)
    .then (repo)->
      console.log("Is the repository bare? %s", Boolean(repo.isBare()));
      repo.getMasterCommit()
    .then (firstCommitOnMaster)->
      history = firstCommitOnMaster.history()
      count = 0

      history.on "commit", (commit)->
        if (++count >= 9)
          return;
        console.log("commit " + commit.sha())
        author = commit.author()
        console.log("Author:\t" + author.name() + " <" + author.email() + ">")
        console.log("Date:\t" + commit.date())
        console.log("\n    " + commit.message())
      history.start()
    .catch (err)->
      console.log "error!! #{err}"
    .done ()->
      console.log "done!"

    msg.send "end!"
