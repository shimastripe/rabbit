# Description:
#   Returns the result of static code analysis
#
# Dependencies:
#   None
#
# Commands:
#   analysis <toolName> (Ex. checkstyle)
#
# Author:
#   Go Takagi

module.exports = (robot) ->

  robot.hear /analysis (.+)/, (res) ->
    toolname = res.match[1]

    Tool = {}
    try
      Tool = require "../analysis-script/#{toolname}"
    catch err
      console.log err
      return res.send "#{toolname} is not found..."

    res.send "Execute analysis of #{toolname}..."

    # TODO Preparation of means for passing option
    options = {}
    t = new Tool options
    t.exec (msg) -> res.send msg
