'use strict'


angular.module('mdApp')


.service 'dndFile', ($rootScope) ->
  # provides Drag 'n' Drop behavoirs for local files
  allowed_file_exts = /\.(md|litcoffee|css)$/

  load_first_file_matching = (files, regexp) =>
    if mdfile = (()->(return f for f in files when regexp.test(f.name)))()
      reader = new FileReader()
      reader.onload = (e) =>
        e.fileName = mdfile.name.replace regexp, ''
        e.fileExt  = mdfile.name.match(regexp)[1]
        @callbacks.fileload(e)
      reader.readAsText(mdfile)

  default_drop = (e) =>
    files = e.dataTransfer.files
    if files.length
      load_first_file_matching files, /\.(md|litcoffee)$/
      load_first_file_matching files, /\.(css)$/

  @callbacks =
    active: (e) ->
    inactive: (e) ->
    fileload: (e) ->
    drop: (e) ->
    default_drop: default_drop

  init: (elm) =>
    elm.addEventListener "dragenter", (e) =>  _.kill_event(e); @callbacks.active(e)
    elm.addEventListener "dragover",  (e) =>  _.kill_event(e); @callbacks.active(e)
    elm.addEventListener "dragexit",  (e) =>  _.kill_event(e); @callbacks.inactive(e)
    elm.addEventListener "drop", (e) =>
      _.kill_event(e)
      @callbacks.drop(e)
      @callbacks.default_drop(e)
  onactive: (cb) => @callbacks.active = cb
  oninactive: (cb) => @callbacks.inactive = cb
  onfileload: (cb) => @callbacks.fileload = cb
  ondrop: (cb, replace_default) =>
    @callbacks.drop = cb
    @callbacks.default_drop = if replace_default then (()->) else default_drop
