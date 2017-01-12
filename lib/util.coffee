urljoin = require 'url-join'
jokeList = (require '../data/joke').joke_list
replyList = (require '../data/joke').reply_list

ADDRESS = process.env.HEROKU_URL or 'http://localhost:8080'

class Util
  constructor: ->

  # static
  @random = (arr)->
    arr[Math.floor Math.random() * arr.length]

  # static
  @joke = ()->
    @random jokeList

  # static
  @jokeReply = ()->
    @random replyList

  # static
  @deleteRequireCache = (name)->
    file = require.resolve name
    if require.cache[file]?
      delete require.cache[file]

  # static
  @getPath = (path...)->
    urljoin ADDRESS, path...

module.exports = Util
