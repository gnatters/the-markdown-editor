'use strict'

describe 'Service: myService', () ->

  # load the service's module
  beforeEach module 'markdownApp'

  # instantiate service
  myService = {}
  beforeEach inject (_myService_) ->
    myService = _myService_

  it 'should do something', () ->
    expect(!!myService).toBe true;
