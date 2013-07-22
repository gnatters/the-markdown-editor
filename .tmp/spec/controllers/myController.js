(function() {
  'use strict';
  describe('Controller: MyControllerCtrl', function() {
    var MyControllerCtrl, scope;
    beforeEach(module('markdownApp'));
    MyControllerCtrl = {};
    scope = {};
    beforeEach(inject(function($controller, $rootScope) {
      scope = $rootScope.$new();
      return MyControllerCtrl = $controller('MyControllerCtrl', {
        $scope: scope
      });
    }));
    return it('should attach a list of awesomeThings to the scope', function() {
      return expect(scope.awesomeThings.length).toBe(3);
    });
  });

}).call(this);
