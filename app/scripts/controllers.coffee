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

angular.module('mdApp')

.controller 'mdCtrl', ($scope, $rootScope, $http, $element, dndFile) ->
  $scope.md_raw = default_md
  $scope.dragover = false

  # drag and drop behavoir
  dndFile.init $element[0]
  dndFile.onactive   () -> $scope.$apply () -> $scope.dragover = true
  dndFile.oninactive () -> $scope.$apply () -> $scope.dragover = false
  $element[0].addEventListener 'mousemove', () -> $scope.$apply () -> $scope.dragover = false
  dndFile.ondrop ((e) -> $scope.$apply () -> $scope.dragover = false), false
  dndFile.onfileload (e) -> $scope.$apply () -> $scope.md_raw = e.target.result

  $scope.style =
    css: ''
    active: 'markdowncss'
    sheets:
      markdowncss:
        source: $rootScope.corsproxy('http://kevinburke.bitbucket.org/markdowncss/markdown.css')
      GitHub:
        source: '/styles/md/github.css'
        # css
        # external
        # edited
    external: ''

  $scope.$watch 'style.active', () ->
    if $scope.style.active of $scope.style.sheets
      style = $scope.style.sheets[$scope.style.active]
      unless style.css
        $http.get(style.source).then (response) -> style.css = response.data

  $scope.$watch 'style.external', () ->
    return unless $scope.style.external
    $http.get($rootScope.corsproxy($scope.style.external)).then (response) ->
      i = 0
      name = "external_#{i}"
      name = "external_#{++i}" while name of $scope.style.sheets
      console.log $scope.style
      $scope.style.sheets[name] =
        source: $scope.style.external
        css: response.data
        external: true
        edited: false
      $scope.style.active = name
      $scope.style.external = ''

  $scope.message = ""
  $scope.$watch 'message', () ->
    t0 = new Date()
    setTimeout (() -> $scope.$apply () -> $scope.message = "" if new Date() - t0 >=5000 ), 5000

