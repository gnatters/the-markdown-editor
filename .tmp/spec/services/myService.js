(function() {
  'use strict';
  describe('Service: myService', function() {
    var myService;
    beforeEach(module('markdownApp'));
    myService = {};
    beforeEach(inject(function(_myService_) {
      return myService = _myService_;
    }));
    return it('should do something', function() {
      return expect(!!myService).toBe(true);
    });
  });

}).call(this);
