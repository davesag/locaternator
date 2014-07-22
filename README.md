locaternator
============

A simple jQuery plugin that uses [freegeoip.net](http://freegeoip.net) to determine where you are, and the closest location to you from a given set of locations.

## Usage

### Prerequsites

The **Locaternator** uses [jQuery](https://jquery.com) and [async](https://github.com/caolan/async) to do its stuff.

### To Use

Your page should expect a `document` level event called "`locaternated`"

```javascript
$(document).ready(function(){
  $(document).on("locaternated", function(evt, location){
    console.log("Found location", location);
    // do fancy stuff with location
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
  $(document).on("locaternated", function(evt, location, locations, closest){
    console.log("Found location", location, "from locations", locations, "closest is", closest);
    // do fancy stuff with location, locations, and closest
  });
  $.Locaternator({
    locations: myLocationsArray // or "/someLocations.json"
  })
});
```
or loaded from a `json` feed / file.

You can add whatever other fields you wish to the location object so long as it has a `name` and `coordinate` fields,
and the `coordinate` field has a `lat` and a `lon` represented as decimal degrees.

### Custom GeoIP server

You can also add options for using a different GeoIP server if, for example, you are
[running your own server](https://github.com/fiorix/freegeoip).

```javascript
$.Locaternator({
  geoIP: {
    jsonURL: "/whatever",
    dataType: "json"
  }
})
```

## Buildage

### First

Assuming you have `Node.js`, `grunt`, and `grunt-cli` installed.

```bash
npm install
```

### To Test

```bash
grunt test
```

### To Build

```bash
grunt
```

This will output the final distribution files into the `dist/` folder, prefixed with `jquery` and suffixed with the version number you specify in `package.json`.

Files created are:

* `jquery-locaternator.1.0.1.js` — the 'developer' version.
* `jquery-locaternator.1.0.1.min.js` — The minified version for production use.
* `jquery-locaternator.1.0.1.min.js.map` — The `sourcemap` file for debugging using the minified version.

## Thanks

Thanks to [freegeoip.net](http://freegeoip.net) for providing such a cool, free service.

### Important Note

*Please don't use this utility to thrash the FreeGeoIP system*

#### Limits

From the [freegeoip.net page](http://freegeoip.net)

> API usage is limited to 10,000 queries per hour.
> After reaching this limit, all requests will result
> in HTTP 403 (Forbidden) until the roll over.

## License

Available for commercial or non-commercial use under the MIT license.
