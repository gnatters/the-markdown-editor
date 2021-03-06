'use strict'

mdApp = angular.module('mdApp', ['ngResource'])

.config(['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
])


_.kill_event = (e) ->
    e.cancelBubble = true
    e.stopPropagation()
    e.preventDefault()


_.corsproxy = (css_url) ->
  m = css_url.match(/https?:\/\/(.+)/)
  return false unless m
  "http://www.corsproxy.com/#{m[1]}"
