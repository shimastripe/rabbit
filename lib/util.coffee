_ = require 'lodash'

module.exports = (robot)->
  obj = {}

  obj.random = (arr)->
    arr[Math.floor Math.random() * arr.length]

  obj.emojideco = (message, name, repeat=1)->
    emo = _.repeat ":#{name}:", repeat
    "#{emo} #{message} #{emo}"

  obj.generateAttachment = (color, extra={})->
    #timestamp = new Date/1000 | 0
    option =
      fallback: 'fallback text'
      color: color
      #ts: timestamp
    _.extend option, extra

  obj.generateFieldAttachment = (color, extra={})->
    extra.fields = []
    obj.generateAttachment color, extra

  obj.generateActionAttachment = (color, callback_id, extra={})->
    extra.actions = []
    extra.callback_id = callback_id
    obj.generateAttachment color, extra

  obj.generateField = (title, value, short=false)->
    option =
      title: title
      value: value
      short: short
    option

  obj.generateButton = (name, value, style="default", extra={})->
    option =
      name: name
      text: name
      type: "button"
      value: value
      style: style
    _.extend option, extra

  obj.generateConfirm = (title, text, ok, cancel, extra={})->
    option =
      title: title
      text: text
      ok_text: ok
      dismiss_text: cancel
    _.extend option, extra

  obj.say = (room, message, extra={})->
    ###
    envelope =
      user:
        type: 'groupchat'
        room: channel_id
      room: channel_id
    robot.send envelope, message
    ###
    options =
      unfurl_links: true
    options = _.extend options, extra
    robot.adapter.client.web.chat.postMessage room, message, options

  obj.sendAttachment = (room, attachments, extra={})->
    options =
      as_user: true
      link_names: 1
      attachments: attachments
    options = _.extend options, extra
    robot.adapter.client.web.chat.postMessage room, '', options

  obj.addReaction = (reaction, room, ts)->
    robot.adapter.client.web.reactions.add reaction,
      timestamp: ts
      channel: room

  return obj
