# 1度出たエラーは返さない (file, lineno, detail一致判断)
AnalysisExecutor = require './base'
path = require "path"
exec = require('child_process').exec
Git = require "../lib/git"
mongoose = require '../lib/mongoose'

CLONE_URL = process.env.GITHUB_CLONE_URL or ''
localPath = path.resolve "tmp/repository"
checkstylePath = path.resolve "checkstyle/checkstyle-7.4-all.jar"

git = new Git()
Checkstyle = mongoose.model 'Checkstyle'

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
    # [WARN] /Users/XXXX/sandbox/gtakagi-chatbot/scripts/tmp/src/main/java/AdminServlet.java:11: のための間違った辞書式順序 'javax.servlet.ServletException' インポート。の前にすべきである 'javax.servlet.http.HttpServletResponse' 。 [CustomImportOrder]
    regexp = new RegExp /\[(WARN|ERROR)\] (.*?):(\d+)(:(\d+))?: (.*) \[(.*)\]/, 'i'
    match = line.match regexp
    if match is null
      return null
    obj =
      signal: match[1]
      file: match[2].split("tmp/repository/")[1]
      lineno: parseInt(match[3], 10)
      sub_lineno: parseInt(match[5], 10) or 0
      detail: match[6]
      type: match[7]

  process: (observable) ->
    observable
    .filter (line) -> line unless null
    .concatMap (x) ->
      # check database
      Checkstyle.find {file: x.file, lineno: x.lineno, sub_lineno: x.sub_lineno, detail: x.detail}
      .then (docs) -> return [x, docs.length is 0]
    .filter (x) -> x[1]
    .do (x, err) ->
      # save database
      Checkstyle.update {file: x[0].file, lineno: x[0].lineno, sub_lineno: x[0].sub_lineno, detail: x[0].detail}, x[0], {upsert: true}, (err) ->
        return console.log err if err
    .reduce ((acc, x, idx, source) ->
      num = "#{x[0].lineno}"
      num += ":#{x[0].sub_lineno}" if x[0].sub_lineno isnt 0
      msg = "[#{x[0].signal}]\n#{x[0].file}:#{num} [#{x[0].type}]\n#{x[0].detail}"
      acc += "\n\n#{msg}"
    ), "[result]"