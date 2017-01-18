# 連続して同じエラーをまとめて表示、ファイルをまたぐ場合はわけて表示
AnalysisExecutor = require './base'
path = require "path"
exec = require('child_process').exec
Git = require "../lib/git"
mongoose = require '../lib/mongoose'
Rx = require 'rx'

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
    .map (obj) ->
      if obj.sub_lineno is 0
        obj.lineno = "#{obj.lineno}"
      else
        obj.lineno = "#{obj.lineno}:#{obj.sub_lineno}"
      delete obj.sub_lineno
      return obj
    .reduce ((acc, x, idx, source) ->
      if acc.length is 0
        acc.push x
        return acc

      last = acc[acc.length - 1]
      if last.file is x.file and last.detail is x.detail
        last.lineno += ",#{x.lineno}"
        acc[acc.length - 1] = last
      else
        acc.push x
      return acc
    ), []
    .flatMap (x) -> Rx.Observable.from x
    .reduce ((acc, x, idx, source) ->
      msg = "[#{x.signal}]\n#{x.file}:#{x.lineno} [#{x.type}]\n#{x.detail}"
      acc += "\n\n#{msg}"
    ), "[result]"
