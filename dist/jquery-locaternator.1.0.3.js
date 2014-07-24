/*!
 * A jQuery plugin for specific location handling - v1.0.3 - 2014-07-24
 * https://github.com/davesag/locaternator
 * Copyright (c) 2014 Dave Sag; Licensed MIT
 */
(function() {
  if (typeof jQuery === "undefined") {
    throw "Expected jQuery to have been loaded before this script.";
  }

  if (typeof async === "undefined") {
    throw "Expected async to have been loaded before this script.";
  }

}).call(this);

(function() {
  (function($, async, document) {
    var distanceBetween, sortByClosest;
    distanceBetween = function(currentLocation, otherLocation) {
      var R, a, a1, a2, c, d1, d2;
      R = 6371;
      a1 = currentLocation.lat * Math.PI / 180;
      a2 = otherLocation.lat * Math.PI / 180;
      d1 = (otherLocation.lat - currentLocation.lat) * Math.PI / 180;
      d2 = (otherLocation.lon - currentLocation.lon) * Math.PI / 180;
      a = Math.sin(d1 / 2) * Math.sin(d1 / 2) + Math.cos(a1) * Math.cos(a2) * Math.sin(d2 / 2) * Math.sin(d2 / 2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
    };
    sortByClosest = function(currentLocation, locations) {
      var distance, loc, result, sloc, sortedLocations, _i, _len;
      sortedLocations = [];
      for (_i = 0, _len = locations.length; _i < _len; _i++) {
        loc = locations[_i];
        distance = distanceBetween(currentLocation, loc.coordinate);
        sortedLocations.push({
          location: loc,
          distance: distance
        });
      }
      sortedLocations.sort(function(a, b) {
        return a.distance - b.distance;
      });
      result = (function() {
        var _j, _len1, _results;
        _results = [];
        for (_j = 0, _len1 = sortedLocations.length; _j < _len1; _j++) {
          sloc = sortedLocations[_j];
          _results.push(sloc.location);
        }
        return _results;
      })();
      return result;
    };
    $.Locaternator = function(options) {
      var getLocation, jobs, loadLocations, opts;
      opts = $.extend(true, {}, $.Locaternator.options);
      this.options = typeof options === "object" ? $.extend(true, opts, options) : opts;
      getLocation = (function(_this) {
        return function(callback) {
          var geoIPOtions;
          geoIPOtions = {
            url: _this.options.geoIP.jsonURL,
            dataType: _this.options.geoIP.dataType
          };
          $.ajax(geoIPOtions).done(function(data) {
            callback(null, data);
          });
        };
      })(this);
      loadLocations = (function(_this) {
        return function(callback) {
          if (!(typeof _this.options.locations === "string" || _this.options.locations instanceof Array)) {
            callback("expected locations option to be a string or array", null);
            return;
          }
          if (_this.options.locations === "") {
            callback(null, []);
            return;
          }
          if (_this.options.locations instanceof Array) {
            callback(null, _this.options.locations);
            return;
          }
          $.get(_this.options.locations, function(data) {
            callback(null, data);
          });
        };
      })(this);
      jobs = {
        location: getLocation,
        locations: loadLocations
      };
      return async.parallel(jobs, function(err, result) {
        var closest, localCoord, sorted;
        if (err) {
          console.error("got error", err);
        } else {
          localCoord = {
            lat: result.location.latitude,
            lon: result.location.longitude
          };
          sorted = sortByClosest(localCoord, result.locations);
          closest = sorted.shift();
          $(document).trigger("locaternated", [result.location, sorted, closest]);
        }
      });
    };
    return $.Locaternator.options = {
      locations: "",
      geoIP: {
        jsonURL: "http://freegeoip.net/json/",
        dataType: "jsonp"
      }
    };
  })(jQuery, async, document);

}).call(this);
