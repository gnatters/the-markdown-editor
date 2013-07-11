'use strict'

describe 'Filter: myFilter', () ->

  # load the filter's module
  beforeEach module 'markdownApp'

  # initialize a new instance of the filter before each test
  myFilter = {}
  beforeEach inject ($filter) ->
    myFilter = $filter 'myFilter'

  it 'should return the input prefixed with "myFilter filter:"', () ->
    text = 'angularjs'
    expect(myFilter text).toBe ('myFilter filter: ' + text);
