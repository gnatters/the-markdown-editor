(function() {
  'use strict';
  describe('Filter: myFilter', function() {
    var myFilter;
    beforeEach(module('markdownApp'));
    myFilter = {};
    beforeEach(inject(function($filter) {
      return myFilter = $filter('myFilter');
    }));
    return it('should return the input prefixed with "myFilter filter:"', function() {
      var text;
      text = 'angularjs';
      return expect(myFilter(text)).toBe('myFilter filter: ' + text);
    });
  });

}).call(this);
