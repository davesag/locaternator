/*!
 * A jQuery plugin for specific location finding and displaying - v1.2.0 - 2016-02-20
 * https://github.com/davesag/locaternator
 * Copyright (c) 2016 Dave Sag; Licensed MIT
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
      var findNearbyPlaceName, getGeoNamesUsername, getLocation, jobs, loadLocations, opts;
      opts = $.extend(true, {}, $.Locaternator.options);
      this.options = typeof options === "object" ? $.extend(true, opts, options) : opts;
      getLocation = (function(_this) {
        return function(callback) {
          if (_this.options.currentLocation) {
            getGeoNamesUsername(function(err, username) {
              return findNearbyPlaceName(_this.options.currentLocation, username, callback);
            });
          } else {
            opts = {
              url: _this.options.service().jsonURL,
              dataType: _this.options.service().dataType
            };
            $.ajax(opts).done(function(data) {
              var loc, locationString;
              loc = {
                latitude: data.latitude,
                longitude: data.longitude,
                name: data.city,
                address: {
                  subnationalDivision: data[_this.options.service().fields.region],
                  country: {
                    name: data[_this.options.service().fields.country],
                    code: data["country_code"]
                  }
                }
              };
              if ((loc.latitude === void 0 || loc.longitude === void 0) && typeof data[_this.options.service().fields.location] === "string") {
                locationString = data[_this.options.service().fields.location].split(",");
                loc.latitude = parseFloat(locationString[0]);
                loc.longitude = parseFloat(locationString[1]);
              }
              callback(null, loc);
            });
          }
        };
      })(this);
      getGeoNamesUsername = (function(_this) {
        return function(next) {
          $.getJSON(_this.options.geonames.account, function(data) {
            next(null, data.username);
          });
        };
      })(this);
      findNearbyPlaceName = function(location, username, next) {
        var ajaxOpts;
        ajaxOpts = {
          url: "http://api.geonames.org/findNearbyPlaceNameJSON?lat=" + location.lat + "&lng=" + location.lon + "&username=" + username + "&maxRows=1",
          dataType: "jsonp",
          success: function(data) {
            var loc, _ref, _ref1, _ref2, _ref3, _ref4;
            if (((_ref = data.geonames) != null ? _ref.length : void 0) > 0) {
              loc = {
                latitude: location.lat,
                longitude: location.lon,
                name: (_ref1 = data.geonames[0]) != null ? _ref1.toponymName : void 0,
                address: {
                  subnationalDivision: (_ref2 = data.geonames[0]) != null ? _ref2.adminName1 : void 0,
                  country: {
                    name: (_ref3 = data.geonames[0]) != null ? _ref3.countryName : void 0,
                    code: (_ref4 = data.geonames[0]) != null ? _ref4.countryCode : void 0
                  }
                }
              };
              return next(null, loc);
            } else {
              console.error("findNearbyPlaceName returned error", data);
              return next(data, null);
            }
          }
        };
        $.ajax(ajaxOpts);
      };
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
          $.getJSON(_this.options.locations, function(data) {
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
          $(document).trigger("locaternated-error", [err]);
        } else {
          localCoord = {
            lat: result.location.latitude,
            lon: result.location.longitude
          };
          sorted = [];
          closest = void 0;
          if (result.locations.length > 0) {
            sorted = sortByClosest(localCoord, result.locations);
            closest = sorted.shift();
          }
          $(document).trigger("locaternated", [result.location, closest, sorted]);
        }
      });
    };
    return $.Locaternator.options = {
      service: function() {
        return this.locationServices[this.locationServices["default"]];
      },
      locations: "",
      locationServices: {
        "default": "ipinfo",
        ipinfo: {
          jsonURL: "http://ipinfo.io",
          dataType: "json",
          fields: {
            region: "region",
            country: "country",
            location: "loc"
          }
        },
        geoIP: {
          jsonURL: "http://freegeoip.net/json/",
          dataType: "jsonp",
          fields: {
            region: "region_name",
            country: "country_name"
          }
        }
      },
      currentLocation: null,
      geonames: {
        account: "/data/geonamesCredentials.json"
      }
    };
  })(jQuery, async, document);

}).call(this);
