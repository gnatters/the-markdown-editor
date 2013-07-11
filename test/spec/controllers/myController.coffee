'use strict'

describe 'Controller: MyControllerCtrl', () ->

  # load the controller's module
  beforeEach module 'markdownApp'

  MyControllerCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    MyControllerCtrl = $controller 'MyControllerCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
