// Generated by CoffeeScript 1.10.0
(function() {
  var CND, CODEC, SELF, Xmap, badge, njs_fs, njs_path, njs_util, rpr;

  njs_util = require('util');

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'Xmap';

  CODEC = require('hollerith-codec');


  /* inspired by
  https://www.reddit.com/r/javascript/comments/4hy2cc/what_is_this_and_is_it_worth_it/
  https://www.npmjs.com/package/hasharray
   */

  SELF = '%self';

  Xmap = (function() {
    function Xmap(iterable) {
      this[SELF] = new Map(iterable);
      Object.defineProperty(this, 'size', {
        get: (function(_this) {
          return function() {
            return _this[SELF].size;
          };
        })(this),
        set: (function(_this) {
          return function(n) {
            return _this[SELF].size = n;
          };
        })(this)
      });
      return this;
    }

    Xmap.prototype.encode = function(key) {
      return (CODEC.encode([key])).toString('binary');
    };

    Xmap.prototype.decode = function(key) {
      return (CODEC.decode(new Buffer(key, 'binary')))[0];
    };

    Xmap.prototype.set = function(key, value) {
      return this[SELF].set(this.encode(key), value);
    };

    Xmap.prototype.get = function(key) {
      return this[SELF].get(this.encode(key));
    };

    Xmap.prototype.has = function(key) {
      return this[SELF].has(this.encode(key));
    };

    Xmap.prototype["delete"] = function(key) {
      return this[SELF]["delete"](this.encode(key));
    };

    Xmap.prototype.clear = function() {
      return this[SELF].clear();
    };

    Xmap.prototype.forEach = function(handler, self) {
      if (self == null) {
        self = this;
      }
      return this[SELF].forEach(((function(_this) {
        return function(value, key, self) {
          return handler(value, _this.decode(key), self);
        };
      })(this)), self);
    };

    Xmap.prototype.keys = function() {
      return (function(_this) {
        return function*() {
          var done, keys, ref, value;
          keys = _this[SELF].keys();
          while (true) {
            ref = keys.next(), value = ref.value, done = ref.done;
            if (done) {
              break;
            }
            (yield _this.decode(value));
          }
          return null;
        };
      })(this)();
    };

    Xmap.prototype.values = function() {
      return (function(_this) {
        return function*() {
          var done, ref, value, values;
          values = _this[SELF].values();
          while (true) {
            ref = values.next(), value = ref.value, done = ref.done;
            if (done) {
              break;
            }
            (yield value);
          }
          return null;
        };
      })(this)();
    };

    Xmap.prototype.entries = function() {
      return (function(_this) {
        return function*() {
          var done, entries, ref, value;
          entries = _this[SELF].entries();
          while (true) {
            ref = entries.next(), value = ref.value, done = ref.done;
            if (done) {
              break;
            }
            (yield [_this.decode(value[0]), value[1]]);
          }
          return null;
        };
      })(this)();
    };

    return Xmap;

  })();

  module.exports = Xmap;

}).call(this);
