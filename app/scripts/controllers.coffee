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

.controller 'mdCtrl', ($scope, $http, $element, dndFile, $filter) ->
  $scope.md_raw = default_md
  $scope.dragover = false

  # drag and drop behavoir
  dndFile.init $element[0],
  dndFile.onactive   () -> $scope.$apply () -> $scope.dragover = true
  dndFile.oninactive () -> $scope.$apply () -> $scope.dragover = false
  $element[0].addEventListener 'mousemove', () -> $scope.$apply () -> $scope.dragover = false
  dndFile.ondrop ((e) -> $scope.$apply () -> $scope.dragover = false), false
  dndFile.onfileload (e) ->
    $scope.$apply () ->
      if e.fileExt in ['md', 'litcoffee']
        $scope.md_raw = e.target.result
      else if e.fileExt is 'css'
        name = e.fileName
        i = 0
        name = "#{e.fileName} #{++i}" while name of $scope.style.sheets
        $scope.style.sheets[name] =
          source: 'dragged file'
          native: false
          css: e.target.result
        $scope.style.active = name

  $element.bind 'click', (e) -> $scope.$broadcast('ctrlClicked')

  $scope.style =
    active: 'markdowncss'
    sheets:
      markdowncss:
        source: _.corsproxy('http://kevinburke.bitbucket.org/markdowncss/markdown.css')
        native: true
      GitHub:
        source: '/styles/md/github.css'
        native: true
    external: ''
    editor: ''

  $scope.copy_style = (e,style_name) ->
    _.kill_event(e)
    copy = _.clone $scope.style.sheets[style_name]
    style_name = style_name.match(/(.*?)(:? copy(:? \d+)?)?$/)[1]
    name = "#{style_name} copy"
    i = 0
    name = "#{style_name} copy #{++i}" while name of $scope.style.sheets
    copy.native = false
    $scope.style.sheets[name] = copy
    $scope.style.active = name


  $scope.delete_style = (e,style_name) ->
    _.kill_event(e)
    delete $scope.style.sheets[style_name]
    $scope.style.active = Object.keys($scope.style.sheets)[0] if $scope.style.active is style_name


  $scope.$watch 'style.active', () ->
    if $scope.style.active of $scope.style.sheets
      style = $scope.style.sheets[$scope.style.active]
      if style.css
        $scope.style.editor = $filter('prettifyCSS')(style.css)
      else
        $http.get(style.source).then (response) ->
          style.css = response.data
          $scope.style.editor = $filter('prettifyCSS')(style.css)

  $scope.$watch 'style.editor', () ->
    style = $scope.style.sheets[$scope.style.active]
    # unless style.edited
    $scope.style.sheets[$scope.style.active].css = $scope.style.editor

  $scope.$watch 'style.external', () ->
    return unless $scope.style.external and /^(https?:\/\/)?(\w+\.)+[\w\/]+/.test $scope.style.external
    $http.get(_.corsproxy($scope.style.external)).then (response) ->
      i = 0
      name = "external"
      name = "external #{++i}" while name of $scope.style.sheets
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


