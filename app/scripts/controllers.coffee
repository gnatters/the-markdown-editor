'use strict'


default_md = "
The Markdown Editor\n
===\n
\n
* Edit's made on the left panel instantly render on the right\n
* Drag the middle divider to resize panels\n
* Drag and drop a `.md` or `.litcoffee` file into this window to load it\n
* <span style='color:pink; background-color:darkred; padding:5px; border-radius:8px'>HTML is allowed too!</span>\n
"


mdApp = angular.module('mdApp')


mdApp.controller 'mdCtrl', ($scope, $rootScope, $http, $element, dndFile) ->
  $scope.md_raw = default_md
  $scope.dragover = false
  dndFile.init $element[0]
  dndFile.onactive   () -> $scope.$apply () -> $scope.dragover = true
  dndFile.oninactive () -> $scope.$apply () -> $scope.dragover = false
  $element[0].addEventListener 'mousemove', () -> $scope.$apply () -> $scope.dragover = false
  dndFile.ondrop ((e) -> $scope.$apply () -> $scope.dragover = false), false
  dndFile.onfileload (e) -> $scope.$apply () -> $scope.md_raw = e.target.result

  $scope.styles =
    css: ''
    active: 'markdowncss'
    show: false
    available:
      markdowncss: $rootScope.corsproxy('http://kevinburke.bitbucket.org/markdowncss/markdown.css')
      GitHub: '/styles/md/github.css'
    external: ''

  $scope.$watch 'styles.active', () ->
    css_location = if $scope.styles.available[$scope.styles.active]
      $scope.styles.available[$scope.styles.active]
    else if $scope.styles.active is 'external' then $rootScope.corsproxy($scope.styles.external)
    if css_location
      $http.get(css_location).then (response) -> $scope.styles.css = response.data

  $scope.$watch 'styles.external', () ->
    if $scope.styles.active is 'external'
      proxyurl = $rootScope.corsproxy($scope.styles.external)
      $http.get(proxyurl).then((response) -> $scope.styles.css = response.data) if proxyurl

  $scope.message = ""
  $scope.$watch 'message', () ->
    t0 = new Date()
    setTimeout (() -> $scope.$apply () -> $scope.message = "" if new Date() - t0 >=5000 ), 5000


