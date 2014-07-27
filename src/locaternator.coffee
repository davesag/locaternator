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
      if @options.currentLocation
        getGeoNamesUsername (err, username) =>
          findNearbyPlaceName @options.currentLocation, username, callback
      else
        geoIPOtions =
          url: @options.geoIP.jsonURL
          dataType: @options.geoIP.dataType
        $.ajax(geoIPOtions).done (data) ->
          loc =
            latitude: data.latitude
            longitude: data.longitude
            name: data.city
            address:
              subnationalDivision: data["region_name"]
              country:
                name: data["country_name"]
                code: data["country_code"]
          console.debug "get location", loc
          callback null, loc
          return
      return

    getGeoNamesUsername = (next) =>
      $.getJSON @options.geonames.account, (data) ->
        # data = JSON.parse(data) if typeof data is "string" # needed for testing.
        next null, data.username
        return
      return

    findNearbyPlaceName = (location, username, next) ->
      ajaxOpts =
        url: "http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{location.lat}&lng=#{location.lon}&username=#{username}&maxRows=1"
        dataType: "jsonp"
        success: (data) ->
          if data.geonames?.length > 0
            loc =
              latitude: location.lat
              longitude: location.lon
              name: data.geonames[0]?.toponymName
              address:
                subnationalDivision: data.geonames[0]?.adminName1
                country:
                  name: data.geonames[0]?.countryName
                  code: data.geonames[0]?.countryCode
            console.debug "get place", loc
            next null, loc
          else
            console.error "findNearbyPlaceName returned error", data
            next data, null
      $.ajax ajaxOpts
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
      $.getJSON @options.locations, (data) ->
        # data = JSON.parse(data) if typeof data is "string" # needed for testing.
        callback null, data
        return
      return
      
    jobs =
      location: getLocation
      locations: loadLocations
    
    # console.debug "running with options", @options
    
    async.parallel jobs, (err, result) ->
      if err
        console.error "got error", err
      else
        localCoord =
          lat: result.location.latitude
          lon: result.location.longitude
        sorted = []
        closest = undefined
        if result.locations.length > 0
          sorted = sortByClosest(localCoord, result.locations)
          closest = sorted.shift()
        $(document).trigger "locaternated", [result.location, closest, sorted]
      return

  # defaults
  $.Locaternator.options =
    locations: ""
    geoIP:
      jsonURL: "http://freegeoip.net/json/"
      dataType: "jsonp"
    currentLocation: null
    geonames:
      account: "/data/geonamesCredentials.json"
) jQuery, async, document

