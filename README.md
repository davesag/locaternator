locaternator
============

A simple, configurable, jQuery plugin that uses either [telize](http://www.telize.com), or 
[freegeoip.net](http://freegeoip.net)  to determine where you are, and the closest location to you
from a given set of locations, and uses [geonames.org](http://www.geonames.org) to retrieve your
local place name information given supplied coordinates if you already know where you are.

### Prerequsites

The **Locaternator** uses

* [jQuery](https://jquery.com), and 
* [async](https://github.com/caolan/async) to do its stuff.

You **must register** with [geonames.org](http://www.geonames.org) to use their API.  It's free (as in beer).
The tests will likely not pass unless you provide your own GeoName username in `test/geonamesCredentials.json`

## Usage

See it in use at [the Bit2Bit CTM Locations page](http://bit2bit.co/ctms.html).

### To Use

Your page should expect either a `document` level event called "`locaternated`" or
an event called "`locaternated-error`", only one of which will be thrown.

```javascript
$(document).ready(function(){
  $(document).on("locaternated", function(evt, location){
    console.log("Found location", location);
    // do fancy stuff with location
  });
  $(document).on("locaternated-error", function(evt, err){
    console.log("Got error", err);
    // handle the error depending on what went wrong.
  });
  $.Locaternator()
});
```

You can also supply an array of locations to compare to your location, either as an `Array` or as the
`url` of an `ajax.get` request.  The array should be of the format

```javascript
var myLocationsArray = [
      {
        name: "brisbane",
        coordinate: {
          lat: -27.4073899,
          lon: 153.0028595
        }
      },
      {
        name: "brighton",
        coordinate: {
          lat: 50.837418,
          lon: -0.1061897
        }
      }
    ]
```

whether provided directly as an array, ala

```javascript
$(document).ready(function(){
  $(document).on("locaternated", function(evt, yourLocation, closest, otherLocations){
    console.log("You are at", yourLocation, "closest is", closest, "remaining locations sorted by distance", otherLocations);
    // do fancy stuff with yourLocation, otherLocations, and closest
  });
  $.Locaternator({
    locations: myLocationsArray // or "/someLocations.json"
  })
});
```
or loaded from a `json` feed / file.

You can add whatever other fields you wish to the location object so long as it has a `name` and `coordinate` fields,
and the `coordinate` field has a `lat` and a `lon` represented as decimal degrees.

In addition you can provide a `currentLocation` object if you already know the current location.
This is of the form `{lat: 0, lon: 0}` eg:

```javascript
$.Locaternator({
  currentLocation: {
    lat: 25.123
    lon: 0.05
  },
  geonames: {
    account: "/data/geonamesCredentials.json" // this is the default.
  }
})
```

Note to use this service you must provide a [geonames.org](http://www.geonames.org) username which will be pulled from a server-side JSON file, thus not exposing it to the outside world.

```json
{
  "username": "yourgeonamesusername"
}
```

The plugin will attempt to look up the place name using [geonames.org's 'findNearbyPlaceName' JSONP api](http://www.geonames.org/export/web-services.html#findNearbyPlaceName).

Note for the test to run you **must** replace the "demo" username with your own registered username.

#### Received Data

The data we get back from either `geonames` or `telize/freegeoip` is coerced into the following uniform structure

```yml
- name: "a name"
  latitude: 0
  longitude: 0
  address:
    subnationalDivision: "a region name"
    country:
      name: "country name"
      code: "ISO_3166-1_alpha-2 code"
```

### Alternative GeoIP servers

You can use the following GeoIP servers by just naming the default.

* '*telize*' - provided by [Telize](http://www.telize.com). <-- The default.
* 'geoIP' - provided by [freegeoip.net](http://www.freegeoip.net), or

```javascript
$.Locaternator({
  locationServices: {
    default: "geoIP" // or 'telize'
  }
})
```


### Custom GeoIP server

You can also add options for using a different GeoIP server if, for example, you are
[running your own server](https://github.com/fiorix/freegeoip).

```javascript
$.Locaternator({
  
  locationServices: {
    default: "myGeoIPServer",
    myGeoIPServer: {
      jsonURL: "/whatever",
      dataType: "jsonp",
      fields: {
        region: "what_they_call_a_region",
        country: "what_they_call_a_country"
      }
    }
  }
})
```

### Defaults

The default options for the plugin are:


```javascript
{
  service: function() {
    return this.locationServices[this.locationServices["default"]];
  },
  locations: "",
  locationServices: {
    "default": "telize",
    telize: {
      jsonURL: "http://www.telize.com/geoip/",
      dataType: "jsonp",
      fields: {
        region: "region",
        country: "country"
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
}
```

You can selectively override anything in the default options object, including the `.service()` method.

## Buildage

If you wish to build the release versions yourself you'll need `Node.js`, `grunt`, and `grunt-cli` installed.

### First

Assuming you have `Node.js`, `grunt`, and `grunt-cli` installed.

```bash
npm install
```

### To Test

First replace the word "demo" with your own registered username **as per the instructions above**, in 
the file `test/geonamesCredentials.json`

Then:

```bash
grunt test
```

### To Build

```bash
grunt
```

This will output the final distribution files into the `dist/` folder, prefixed with `jquery`
and suffixed with the version number you specify in `package.json`.

Files created are:

* `jquery-locaternator.1.1.0.js` — the 'developer' version.
* `jquery-locaternator.1.1.0.min.js` — The minified version for production use.
* `jquery-locaternator.1.1.0.min.js.map` — The `sourcemap` file for debugging using the minified version.

## Thanks

Thanks to [telize.com](http://www.telize.com) for providing such a cool, working free service.
Thanks to [freegeoip.net](http://www.freegeoip.net) for providing the original such cool, free service.
Thanks to [geonames.org](http://www.geonames.org) for also providing such a cool free service.

### Important Note

1. Please *don't* use this utility to thrash the Telize and FreeGeoIP systems
2. Please *register* with [geonames.org](http://www.geonames.org) before running the tests, or the tests will most likely fail.

#### Limits

If you choose to use the [freegeoip.net service](http://freegeoip.net) take note of this
from the [freegeoip.net page](http://freegeoip.net)

> API usage is limited to 10,000 queries per hour.
> After reaching this limit, all requests will result
> in HTTP 403 (Forbidden) until the roll over.

See [Geonames' credits system](http://www.geonames.org/export/credits.html) for more on how their system works.

### Version History

Release `1.1.0`

* Updated to use `Telize` as the default for Geo IP lookups. We retian FreeGEOIP as an option but it seems to be less reliable.

Release `1.0.5`

* You can now easily specify your own GeoIP  lookup services too.

Release `1.0.0`

* first release

## License

Available for commercial or non-commercial use under the MIT license.
