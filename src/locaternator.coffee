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

  sortByClosest = (currentLocation, locations) ->
    sortedLocations = []
    for loc in locations
      distance = distanceBetween(currentLocation, loc.coordinate)
      sortedLocations.push({location: loc, distance: distance})
    sortedLocations.sort (a,b) ->
      return a.distance - b.distance
    result = (sloc.location for sloc in sortedLocations)
    return result

  # Main jQuery method.
  $.Locaternator = (options) ->
    opts = $.extend true, {}, $.Locaternator.options
    @options = if typeof options is "object" then $.extend(true, opts, options) else opts

    getLocation = (callback) =>
      geoIPOtions =
        url: @options.geoIP.jsonURL
        dataType: @options.geoIP.dataType
      $.ajax(geoIPOtions).done (data) ->
        callback null, data
        return
      return

    loadLocations = (callback) =>
      unless typeof @options.locations is "string" or @options.locations instanceof Array
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
        sorted = sortByClosest(localCoord, result.locations)
        closest = sorted.shift()
        $(document).trigger "locaternated", [result.location, sorted, closest]
      return

  # defaults
  $.Locaternator.options =
    locations: ""
    geoIP:
      jsonURL: "http://freegeoip.net/json/"
      dataType: "jsonp"
) jQuery, async, document

