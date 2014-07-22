locaternator
============

A simple jQuery plugin that uses freegeoip.net to determine where you are, and the closest location to you from a given set of locations

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
[
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
### First

Assuming you have `Node.js` installed.

```bash
npm install
```

## To Test

```bash
grunt test
```

### To Build

```bash
grunt
```

This will output the final distribution files into the `dist/` folder, prefixed with `jquery` and suffixed with the version number you specify in `package.json`.

Files created are:

* `jquery-locaternator.1.0.0.js` — the 'developer' version.
* `jquery-locaternator.1.0.0.min.js` — The minified version for production use.
* `jquery-locaternator.1.0.0.min.js.map` — The `sourcemap` file for debugging using the minified version.

