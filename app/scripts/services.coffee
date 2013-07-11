'use strict'


angular.module('mdApp')


.service 'dndFile', ($rootScope) ->
  # provides Drag aNd Drop behavoirs for local files
  default_drop = (e) =>
    files = e.dataTransfer.files
    count = files.length
    if count
      if file = (()->(return f for f in files when /.(md|litcoffee)$/.test(f.name)))()
        reader = new FileReader()
        reader.onload = @callbacks.fileload
        reader.readAsText(file)

  @callbacks =
    active: (e) ->
    inactive: (e) ->
    fileload: (e) ->
    drop: (e) ->
    default_drop: default_drop

  init: (elm) =>
    elm.addEventListener "dragenter", (e) =>  $rootScope.kill_event(e); @callbacks.active(e)
    elm.addEventListener "dragover",  (e) =>  $rootScope.kill_event(e); @callbacks.active(e)
    elm.addEventListener "dragexit",  (e) =>  $rootScope.kill_event(e); @callbacks.inactive(e)
    elm.addEventListener "drop", (e) =>
      $rootScope.kill_event(e)
      @callbacks.drop(e)
      @callbacks.default_drop(e)
  onactive: (cb) => @callbacks.active = cb
  oninactive: (cb) => @callbacks.inactive = cb
  onfileload: (cb) => @callbacks.fileload = cb
  ondrop: (cb, replace_default) =>
    @callbacks.drop = cb
    @callbacks.default_drop = if replace_default then (()->) else default_drop