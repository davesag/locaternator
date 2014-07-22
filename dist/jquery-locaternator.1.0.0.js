/*!
 * A jQuery plugin for specific location handling - v1.0.0 - 2014-07-22
 * https://github.com/davesag/locaternator
 * Copyright (c) 2014 Dave Sag; Licensed MIT
 */
(function() {
  (function($, async, document) {
    var closestLocationFinder, distanceBetween;
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
    closestLocationFinder = function(currentLocation, locations) {
      var distance, loc, none, shortest, _i, _len;
      none = {
        name: none,
        coordinate: {
          lat: null,
          lon: null
        }
      };
      shortest = [none, 100000000000];
      for (_i = 0, _len = locations.length; _i < _len; _i++) {
        loc = locations[_i];
        distance = distanceBetween(currentLocation, loc.coordinate);
        if (distance < shortest[1]) {
          shortest = [loc, distance];
        }
      }
      return shortest[0];
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
          if (!(_this.options.locations instanceof String || _this.options.locations instanceof Array)) {
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
        var closest, localCoord;
        if (err) {
          console.error("got error", err);
        } else {
          localCoord = {
            lat: result.location.latitude,
            lon: result.location.longitude
          };
          closest = closestLocationFinder(localCoord, result.locations);
          $(document).trigger("locaternated", [result.location, result.locations, closest]);
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
