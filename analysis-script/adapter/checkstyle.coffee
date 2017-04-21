# 1度出たエラーは返さない (file, lineno, detail一致判断)
AnalysisExecutor = require './base'
path = require "path"
exec = require('child_process').exec
Git = require "../../lib/git"

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.resolve "tmp/repository"
checkstylePath = path.resolve "checkstyle/checkstyle-7.4-all.jar"

git = new Git()

module.exports = class CheckStyleExecutor extends AnalysisExecutor
  constructor: (@options) ->
    super 'checkstyle', @options

  exec: (cb) ->
    git.cloneOrOpenRepo CLONE_URL, localPath, "origin/master"
    .then =>
      options =
        cwd: localPath
        maxBuffer: 1024 * 500

      exec 'java -jar ' + checkstylePath + ' -c /google_checks.xml src/main/java', options, (err, stdout, stderr) =>
        console.error  err if err
        console.error  stderr if stderr
        @observe stdout, cb

    .catch (err) -> cb "#{err}"

  toIterable: (raw) -> raw.split '\n'

  parse: (line) ->
    obj = {}
    regexp = new RegExp /\[(WARN|ERROR)\] (.*?):(\d+)(:(\d+))?: (.*) \[(.*)\]/, 'i'
    match = line.match regexp
    if match is null
      return null
    obj =
      signal: match[1]
      file: match[2]
      lineno: parseInt(match[3], 10)
      sub_lineno: parseInt(match[5], 10) or 0
      detail: match[6]
      type: match[7]

  formatMessage: (msg) -> "[#{msg.signal}]\n#{msg.file}:#{msg.lineno} [#{msg.type}]\n#{msg.detail}"

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .reduce ((acc, x) => acc += "\n\n#{@formatMessage x}"), "[result]"
