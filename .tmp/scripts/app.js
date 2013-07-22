(function() {
  'use strict';
  var mdApp;

  mdApp = angular.module('mdApp', ['ngResource']).config([
    '$httpProvider', function($httpProvider) {
      $httpProvider.defaults.useXDomain = true;
      return delete $httpProvider.defaults.headers.common['X-Requested-With'];
    }
  ]);

  _.kill_event = function(e) {
    e.cancelBubble = true;
    e.stopPropagation();
    return e.preventDefault();
  };

  _.corsproxy = function(css_url) {
    var m;
    m = css_url.match(/https?:\/\/(.+)/);
    if (!m) {
      return false;
    }
    return "http://www.corsproxy.com/" + m[1];
  };

}).call(this);
