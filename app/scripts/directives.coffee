'use strict'


angular.module('mdApp')


.directive 'colWidth', () ->
  restrict: 'A'
  scope: false
  link: (scope, elm, attrs) ->
    colWidth = attrs.colWidth.split(/\s*,\s*/).map (s) -> parseFloat(s)
    new_col =
      index: colWidth[0]
      ratio: colWidth[1]
      percentage: "#{colWidth[1]*100}%"
    scope.cols[colWidth[0]] = new_col


.directive 'dragarea', () ->
  restrict: 'A'
  replace: true
  template: '<div class="dragarea">:</div>'
  scope: false
  link: (scope, elm, attrs) ->
    elm.bind 'mousedown', (e) ->
      scope.drag.target = attrs.dragarea
      scope.drag.start = e.clientX
      scope.drag.before = scope.cols[scope.drag.target].ratio
      scope.drag.target = parseInt(scope.drag.target)
      scope.drag.after = scope.cols[parseInt(scope.drag.target)+1].ratio
      e.preventDefault()


.directive 'themeSelector', ($rootScope) ->
  restrict: 'E'
  replace: true
  template: '
<div id="theme-selector">
  <span>Theme ▾</span>
  <ul class="list" ng-show="styles.show">
    <li ng-repeat="(style, location) in styles.available" ng-click="styles.active=style" ng-class="{active_style:styles.active==style}">{{style}}</li>
    <li ng-click="styles.active=\'external\'" ng-class="{active_style:styles.active==\'external\'}">
    	<label for="external-css">External:</label>
    	<input id="styles_external" ng-model="styles.external" ng-click="clicked_input($event)" ng-keydown="keydown_input($event)" type="text" name="external-css" id="external-css" placeholder="http://">
    </li>
  </ul>
</div>'
  link: (scope, elm, attrs) ->
    elm.children()[0].addEventListener 'click', (e) ->
      $rootScope.kill_event(e)
      scope.$apply () -> scope.styles.show = !scope.styles.show # toggle styles menu

    scope.clicked_input = (e) ->
      $rootScope.kill_event(e)
      scope.styles.active = 'external'

    styles_external.onkeydown = (e) ->
      if (e.which or e.keyCode) is 13
        scope.$apply () ->
          scope.styles.active = 'external'
          scope.styles.show = false

