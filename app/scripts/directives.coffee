'use strict'

angular.module('mdApp')


.directive 'adjustableRow', () ->
  restrict: 'E'
  transclude: true
  scope: {}
  replace: true
  template: '<div class="adjustable-row" ng-transclude></div>'
  controller: ($scope, $element, $compile) ->
    $scope.row = $element[0]
    cols = $scope.$parent.cols = $scope.cols = []

    this.equalCols = (ncols) ->
      ncols ||= (c for c in cols when c.show).length
      new_ratio = 1/ncols
      for c in cols
        if c.show
          c.ratio = new_ratio
          c.percentage = "#{new_ratio*100}%"
          c.right_percentage = right_percentage(c.index)
        else
          c.ratio = 0
          c.percentage = "0%"
          c.right_percentage = right_percentage(c.index)

    this.findLastCol = () ->
      last_shown = null
      for c in cols
        c.last_shown = false
        last_shown = c if c.show
      last_shown.last_shown = true if last_shown

    this.addCol = (col) ->
      $scope.$apply () =>
        col.index = cols.length
        cols.push col
        this.equalCols()
        col.div.append $compile('<dragarea ng-show="!last_shown"></dragarea>')(col)

    right_percentage = (index) ->
      "#{((c.ratio for c in cols when c.index <= index).reduce(((t, s) -> t + s), 0))*100}%"

    dragged = (x) =>
      $scope.$apply () =>
        before = $scope.dragging
        after = cols[i = before.index+1]
        after = cols[++i] until after.show # could inifinite loop, but should never
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
      _.kill_event(e)
      $scope.dragging = col

    document.onmousemove = (e) ->
      _.kill_event(e)
      dragged(e.clientX) if $scope.dragging

    document.onmouseup = () -> $scope.dragging = null


.directive 'adjustablecol', () ->
  require: '^adjustableRow'
  restrict: 'E'
  transclude: true
  scope:
    name: '@'
    show: '@'
  replace: true
  template: '<div class="adjustable-col" ng-transclude ng-style="{width: percentage}" ng-show="show"></div>'
  controller: ($scope) ->
    $scope.$watch 'show', () ->
      $scope.ctrl.equalCols()
      $scope.ctrl.findLastCol()

  link: (scope, elm, attrs, adjustableRowCtrl) ->
    scope.div = elm
    scope.ctrl = adjustableRowCtrl
    setTimeout (() -> scope.show = !!scope.show; adjustableRowCtrl.addCol(scope)), 0

.directive 'dragarea', () ->
  restrict: 'E'
  replace: true
  template: '<div class="dragarea" ng-style="{left: right_percentage}">፧</div>'
  scope: false
  link: (scope, elm, attrs) ->
    elm.bind 'mousedown', (e) -> scope.ctrl.start_drag(scope, e)


.controller 'menuCtrl', ($scope, $element, $rootScope) ->
  $scope.show = false
  $scope.$on 'ctrlClicked', () -> $scope.$apply -> $scope.show = false

  $element[0].children[0].addEventListener 'click', (e) ->
    _.kill_event(e)
    show = $scope.show = !$scope.show
    $rootScope.$broadcast 'ctrlClicked'
    $scope.$apply () -> $scope.show = show


.directive 'themeMenu', ($rootScope) ->
  restrict: 'E'
  replace: true
  scope: true
  template:
    '<div id="theme-menu" class="menu">' +
      '<span class="menu-title">Themes ▾</span>' +
      '<ul class="menu-items" ng-show="show">' +
        '<li class="menu-item" ng-repeat="(style, props) in style.sheets" ng-click="$parent.style.active=style" ng-class="{active_style:$parent.style.active==style}">{{style}}' +
          '<ul class="menu-actions">' +
            '<li class="icon-trash" ng-click="!props.native && delete_style($event, style)" ng-class="{inactive:props.native}" title="Delete styles"></li>' +
            '<li class="icon-copy" ng-click="copy_style($event, style)" title="Duplicate styles"></li>' +
            '<li class="icon-save" ng-show="false" title="Save styles"></li>' +
          '</ul>' +
        '</li>' +
        '<li class="menu-item" ng-click="select_ext($event)" ng-class="{active_style:style.active==\'external\'}">' +
        	'<label for="external-css">External: </label>' +
        	'<input id="styles_external" ng-model="style.external"  ng-keydown="keydown_input($event)" type="text" name="external-css" id="external-css" placeholder="http://">' +
        '</li>' +
      '</ul>' +
    '</div>'
  controller: 'menuCtrl'
  link: (scope, elm, attrs, $rootScope) ->
    scope.select_ext = (e) ->
      _.kill_event(e)
      styles_external.focus()

    styles_external.onkeydown = (e) ->
      if (e.which or e.keyCode) is 13
        scope.$apply () ->
          scope.show = false


.directive 'viewMenu', ($rootScope) ->
  restrict: 'E'
  replace: true
  scope: true
  template:
    '<div id="view-menu" class="menu">' +
      '<span class="menu-title">View ▾</span>' +
      '<ul class="menu-items" ng-show="show">' +
        '<li class="menu-item" ng-repeat="col in cols" ng-class="{active_col:col.show}" ng-click="col.show=!col.show">{{col.name}}</li>' +
      '</ul>' +
    '</div>'
  controller: 'menuCtrl'

