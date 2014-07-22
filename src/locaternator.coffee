(($, async, document) ->

  distanceBetween = (currentLocation, otherLocation) ->
    R = 6371 # km
    a1 = currentLocation.lat * Math.PI / 180
    a2 = otherLocation.lat * Math.PI / 180
    d1 = (otherLocation.lat - currentLocation.lat) * Math.PI / 180
    d2 = (otherLocation.lon - currentLocation.lon) * Math.PI / 180
    a = Math.sin(d1 / 2) * Math.sin(d1 / 2) + Math.cos(a1) * Math.cos(a2) * Math.sin(d2 / 2) * Math.sin(d2 / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c

  closestLocationFinder = (currentLocation, locations) ->
    #loop over offices, calculate distance, new hash of office name: distance, sort by distance, then select top
    none =
      name: none
      coordinate:
        lat: null
        lon: null
    shortest = [none, 100000000000]
    for loc in locations
      distance = distanceBetween(currentLocation, loc.coordinate)
      shortest = [loc, distance] if distance < shortest[1]
    return shortest[0]

  # Main jQuery method.
  $.Locaternator = (options) ->
    opts = $.extend true, {}, $.Locaternator.options
    @options = if typeof options is "object" then $.extend(true, opts, options) else opts

    getLocation = (callback) ->
      geoIPOtions =
        url: "http://freegeoip.net/json/"
        dataType: "jsonp"
      $.ajax(geoIPOtions).done (data) ->
        callback null, data
        return
      return

    loadLocations = (callback) =>
      unless @options.locations instanceof String or @options.locations instanceof Array
        callback("expected locations option to be a string or array", null)
        return
      if @options.locations is ""
        callback null, []
        return
      if @options.locations instanceof Array
        callback null, @options.locations
        return
      $.get @options.locations, (data) ->
        callback null, data
        return
      return
      
    jobs =
      location: getLocation
      locations: loadLocations
    async.parallel jobs, (err, result) ->
      if err
        console.error "got error", err
      else
        localCoord =
          lat: result.location.latitude
          lon: result.location.longitude
        closest = closestLocationFinder(localCoord, result.locations)
        $(document).trigger "locaternated", [result.location, result.locations, closest]
      return

  # defaults
  $.Locaternator.options =
    locations: ""
) jQuery, async, document

