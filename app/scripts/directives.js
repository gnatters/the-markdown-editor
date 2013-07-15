// Generated by CoffeeScript 1.6.2
'use strict';
var kill_event;

kill_event = function(e) {
  e.cancelBubble = true;
  e.stopPropagation();
  return e.preventDefault();
};

angular.module('mdApp').directive('adjustableRow', function() {
  return {
    restrict: 'E',
    transclude: true,
    scope: {},
    replace: true,
    template: '<div class="adjustable-row" ng-transclude></div>',
    controller: function($scope, $element, $compile, $rootScope) {
      var cols, dragged, right_percentage,
        _this = this;

      $scope.row = $element[0];
      cols = $scope.cols = [];
      this.addCol = function(col) {
        var c, len, new_ratio, prev_col, _i, _len;

        len = cols.length;
        new_ratio = 1 / (len + 1);
        for (_i = 0, _len = cols.length; _i < _len; _i++) {
          c = cols[_i];
          c.ratio = new_ratio;
          c.percentage = "" + (new_ratio * 100) + "%";
          c.right_percentage = right_percentage(c.index);
        }
        col.index = len;
        col.ratio = new_ratio;
        col.percentage = "" + (new_ratio * 100) + "%";
        cols.push(col);
        if (col.index > 0) {
          prev_col = cols[col.index - 1];
          return prev_col.div.append($compile('<dragarea></dragarea>')(prev_col));
        }
      };
      right_percentage = function(index) {
        var c;

        return "" + ((((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = cols.length; _i < _len; _i++) {
            c = cols[_i];
            if (c.index <= index) {
              _results.push(c.ratio);
            }
          }
          return _results;
        })()).reduce((function(t, s) {
          return t + s;
        }), 0)) * 100) + "%";
      };
      dragged = function(x) {
        return $scope.$apply(function() {
          var after, before, c, cumRatio, i;

          before = $scope.dragging;
          after = cols[before.index + 1];
          cumRatio = ((function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = cols.length; _i < _len; _i++) {
              c = cols[_i];
              if (c.index < before.index) {
                _results.push(c.ratio);
              }
            }
            return _results;
          })()).reduce((function(t, s) {
            return t + s;
          }), 0);
          before.ratio = x / _this.row_width - cumRatio;
          if (before.ratio < 0.1) {
            before.ratio = 0.1;
          }
          after.ratio = 1 - ((function() {
            var _results;

            _results = [];
            for (i in cols) {
              if (parseInt(i) !== after.index) {
                _results.push(cols[i].ratio);
              }
            }
            return _results;
          })()).reduce((function(t, s) {
            return t + s;
          }), 0);
          if (after.ratio < 0.1) {
            after.ratio = 0.1;
            before.ratio = 1 - ((function() {
              var _results;

              _results = [];
              for (i in cols) {
                if (parseInt(i) !== before.index) {
                  _results.push(cols[i].ratio);
                }
              }
              return _results;
            })()).reduce((function(t, s) {
              return t + s;
            }), 0);
          }
          before.percentage = "" + (before.ratio * 100) + "%";
          after.percentage = "" + (after.ratio * 100) + "%";
          return before.right_percentage = right_percentage(before.index);
        });
      };
      (window.onresize = function() {
        return _this.row_width = $scope.row.offsetWidth;
      })();
      this.start_drag = function(col, e) {
        $rootScope.kill_event(e);
        return $scope.dragging = col;
      };
      document.onmousemove = function(e) {
        $rootScope.kill_event(e);
        if ($scope.dragging) {
          return dragged(e.clientX);
        }
      };
      return document.onmouseup = function() {
        return $scope.dragging = null;
      };
    }
  };
}).directive('adjustablecol', function() {
  return {
    require: '^adjustableRow',
    restrict: 'E',
    transclude: true,
    scope: {},
    replace: true,
    template: '<div class="adjustable-col" ng-transclude ng-style="{width: percentage}"></div>',
    link: function(scope, elm, attrs, adjustableRowCtrl) {
      scope.div = elm;
      adjustableRowCtrl.addCol(scope);
      return scope.ctrl = adjustableRowCtrl;
    }
  };
}).directive('dragarea', function() {
  return {
    restrict: 'E',
    replace: true,
    template: '<div class="dragarea" ng-style="{left: right_percentage}">፧</div>',
    scope: false,
    link: function(scope, elm, attrs) {
      return elm.bind('mousedown', function(e) {
        return scope.ctrl.start_drag(scope, e);
      });
    }
  };
}).directive('themeSelector', function($rootScope) {
  return {
    restrict: 'E',
    replace: true,
    template: '<div id="theme-selector">' + '<span>Theme ▾</span>' + '<ul class="list" ng-show="styles.show">' + '<li ng-repeat="(style, location) in styles.available" ng-click="styles.active=style" ng-class="{active_style:styles.active==style}">{{style}}</li>' + '<li ng-click="styles.active=\'external\'" ng-class="{active_style:styles.active==\'external\'}">' + '<label for="external-css">External:</label>' + '<input id="styles_external" ng-model="styles.external" ng-click="clicked_input($event)" ng-keydown="keydown_input($event)" type="text" name="external-css" id="external-css" placeholder="http://">' + '</li>' + '</ul>' + '</div>',
    link: function(scope, elm, attrs, $rootScope) {
      elm.children()[0].addEventListener('click', function(e) {
        kill_event(e);
        return scope.$apply(function() {
          return scope.styles.show = !scope.styles.show;
        });
      });
      scope.clicked_input = function(e) {
        kill_event(e);
        return scope.styles.active = 'external';
      };
      return styles_external.onkeydown = function(e) {
        if ((e.which || e.keyCode) === 13) {
          return scope.$apply(function() {
            scope.styles.active = 'external';
            return scope.styles.show = false;
          });
        }
      };
    }
  };
});