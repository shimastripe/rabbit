path = require "path"
nodeGit = require "nodegit"
_ = require 'lodash'

cloneOptions = {}
cloneOptions.fetchOpts = callbacks:
  certificateCheck: ->
    1
  credentials: ->
    nodeGit.Cred.userpassPlaintextNew process.env.GITHUB_TOKEN, 'x-oauth-basic'

class Git
  constructor: ->

  cloneOrOpenRepo: (url, dir, option) ->
    nodeGit.Repository.open(dir).catch ->
      nodeGit.Clone url, dir, (_.extend cloneOptions, option)

  fetchRepo: (url, dir, option) ->
    @cloneOrOpenRepo(url, dir, option)
    .then (repo) ->
      new Promise (resolve, reject) ->
        repo.fetchAll(_.extend cloneOptions.fetchOpts, option)
        .then -> resolve repo

  pullRepo: (url, dir, branch, option) ->
    @fetchRepo(url, dir, option)
    .then (repo) ->
      repo.mergeBranches("master", branch)

  commitHistory: (url, dir, option) ->
    @cloneOrOpenRepo(url, dir, option)
    .then (repo) ->
      repo.getMasterCommit()
    .then (firstCommitOnMaster)->
      firstCommitOnMaster.history()
    .catch (err)->
      console.log "error!! #{err}"

module.exports = Git
