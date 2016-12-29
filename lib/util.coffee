urljoin = require 'url-join'

ADDRESS = process.env.HEROKU_URL or 'http://localhost:8080'

class Util
  constructor: ->

  # static
  @random = (arr)->
    arr[Math.floor Math.random() * arr.length]

  # static
  @deleteRequireCache = (name)->
    file = require.resolve name
    if require.cache[file]?
      delete require.cache[file]

  #static
  @getPath = (path...)->
    urljoin ADDRESS, path...

module.exports = Util
