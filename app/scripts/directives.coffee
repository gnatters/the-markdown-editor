'use strict'

kill_event = (e) ->
    e.cancelBubble = true
    e.stopPropagation()
    e.preventDefault()

angular.module('mdApp')


.directive 'adjustableRow', () ->
  restrict: 'E'
  transclude: true
  scope: {}
  replace: true
  template: '<div class="adjustable-row" ng-transclude></div>'
  controller: ($scope, $element, $compile, $rootScope) ->
    $scope.row = $element[0]
    cols = $scope.cols = []
    this.addCol = (col) ->
      len = cols.length
      new_ratio = 1/(len+1)
      for c in cols
        c.ratio = new_ratio
        c.percentage = "#{new_ratio*100}%"
        c.right_percentage = right_percentage(c.index)
      col.index = len
      col.ratio = new_ratio
      col.percentage = "#{new_ratio*100}%"
      cols.push col

      if col.index > 0
        prev_col = cols[col.index-1]
        prev_col.div.append $compile('<dragarea></dragarea>')(prev_col)

    right_percentage = (index) ->
      "#{((c.ratio for c in cols when c.index <= index).reduce(((t, s) -> t + s), 0))*100}%" #errrr

    dragged = (x) =>
      $scope.$apply () =>
        before = $scope.dragging
        after = cols[before.index+1]
        cumRatio = (c.ratio for c in cols when c.index < before.index).reduce(((t, s) -> t + s), 0)
        before.ratio = x / this.row_width - cumRatio

        if before.ratio < 0.1
          before.ratio = 0.1
        after.ratio = 1 - (cols[i].ratio for i of cols when parseInt(i) isnt after.index).reduce(((t, s) -> t + s), 0)
        if after.ratio < 0.1
          after.ratio = 0.1
          before.ratio = 1 - (cols[i].ratio for i of cols when parseInt(i) isnt before.index).reduce(((t, s) -> t + s), 0)

        before.percentage = "#{before.ratio*100}%"
        after.percentage  = "#{after.ratio*100}%"
        before.right_percentage = right_percentage(before.index)

    (window.onresize = () => this.row_width = $scope.row.offsetWidth)()

    this.start_drag = (col, e) ->
      $rootScope.kill_event(e)
      $scope.dragging = col

    document.onmousemove = (e) ->
      $rootScope.kill_event(e)
      dragged(e.clientX) if $scope.dragging

    document.onmouseup = () -> $scope.dragging = null


.directive 'adjustablecol', () ->
  require: '^adjustableRow'
  restrict: 'E'
  transclude: true
  scope: {}
  replace: true
  template: '<div class="adjustable-col" ng-transclude ng-style="{width: percentage}"></div>'
  link: (scope, elm, attrs, adjustableRowCtrl) ->
    scope.div = elm
    adjustableRowCtrl.addCol(scope)
    scope.ctrl = adjustableRowCtrl


.directive 'dragarea', () ->
  restrict: 'E'
  replace: true
  template: '<div class="dragarea" ng-style="{left: right_percentage}">፧</div>'
  scope: false
  link: (scope, elm, attrs) ->
    elm.bind 'mousedown', (e) -> scope.ctrl.start_drag(scope, e)


.directive 'themeSelector', ($rootScope) ->
  restrict: 'E'
  replace: true
  template:
    '<div id="theme-selector">' +
      '<span>Theme ▾</span>' +
      '<ul class="list" ng-show="styles.show">' +
        '<li ng-repeat="(style, location) in styles.available" ng-click="styles.active=style" ng-class="{active_style:styles.active==style}">{{style}}</li>' +
        '<li ng-click="styles.active=\'external\'" ng-class="{active_style:styles.active==\'external\'}">' +
        	'<label for="external-css">External:</label>' +
        	'<input id="styles_external" ng-model="styles.external" ng-click="clicked_input($event)" ng-keydown="keydown_input($event)" type="text" name="external-css" id="external-css" placeholder="http://">' +
        '</li>' +
      '</ul>' +
    '</div>'
  link: (scope, elm, attrs, $rootScope) ->
    elm.children()[0].addEventListener 'click', (e) ->
      kill_event(e)
      scope.$apply () -> scope.styles.show = !scope.styles.show # toggle styles menu

    scope.clicked_input = (e) ->
      kill_event(e)
      scope.styles.active = 'external'

    styles_external.onkeydown = (e) ->
      if (e.which or e.keyCode) is 13
        scope.$apply () ->
          scope.styles.active = 'external'
          scope.styles.show = false

