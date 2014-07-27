(($) ->
  ###
    ======== A Handy Little QUnit Reference ========
    http://api.qunitjs.com/

    Test methods:
      module(name, {[setup][ ,teardown]})
      test(name, callback)
      expect(numberOfAssertions)
      stop(increment)
      start(decrement)
    Test assertions:
      ok(value, [message])
      equal(actual, expected, [message])
      notEqual(actual, expected, [message])
      deepEqual(actual, expected, [message])
      notDeepEqual(actual, expected, [message])
      strictEqual(actual, expected, [message])
      notStrictEqual(actual, expected, [message])
      throws(block, [expected], [message])
  ###

  QUnit.skipTest = ->
    QUnit.test "#{arguments[0]} (SKIPPED)", ->
      QUnit.expect 0 # dont expect any tests
      $li = $("##{QUnit.config.current.id}")
      QUnit.done ->
        $li.css "background", "#FFFF99"
  skipTest = QUnit.skipTest

  module "simple tests",

  asyncTest "finds a current location", ->
    $(document).on "locaternated", (evt, location, closest, otherLocations) ->
      notEqual evt, null, "expected the event to not be null"
      equal typeof location.latitude, "number", "expected the location's latitude to be a number, not #{typeof location.latitude}"
      equal typeof closest, "undefined", "expected the closest location to be 'undefined'"
      equal otherLocations.length, 0, "expected the locations array to be empty"
      console.debug "location", location, "closest", closest, "other locations", otherLocations
      $(document).off "locaternated"
      start()
    $.Locaternator()

  module "local location data test",
  
    setup: ->
      @testLocations = [
        {
          name: "brisbane"
          coordinate:
            lat: -27.4073899
            lon: 153.0028595
        }
        {
          name: "brighton"
          coordinate:
            lat: 50.837418,
            lon: -0.1061897
        }
      ]

  asyncTest "finds a current location, closest location, and other locations given an array of locations.", ->
    $(document).on "locaternated", (evt, location, closest, otherLocations) ->
      notEqual evt, null, "expected the event to not be null"
      equal typeof location.latitude, "number", "expected the location's latitude to be a number, not #{typeof location.latitude}"
      ok closest.name, "expected the closest location to have a name"
      equal otherLocations.length, 1, "expected the locations array to only have one element"
      console.debug "location", location, "closest", closest, "other locations", otherLocations
      $(document).off "locaternated"
      start()
    $.Locaternator({locations: @testLocations})

  # note: for this test to pass you must replace the "demo" username with a valid username
  #       that has not run out of credits for the day.
  # see http://www.geonames.org
  asyncTest "finds a current location name given currentLocation, as well as closest location, and other locations given an array of locations.", ->
    $(document).on "locaternated", (evt, location, closest, otherLocations) ->
      notEqual evt, null, "expected the event to not be null"
      equal location.latitude, -35.267852, "expected the location's latitude to be a the one supplied"
      equal location.name, "Turner", "expected the location's name to be 'Turner'"
      equal closest.name, "brisbane", "expected the closest location to be 'brisbane'"
      equal otherLocations.length, 1, "expected the locations array to have three elements"
      console.debug "location", location, "closest", closest, "other locations", otherLocations
      $(document).off "locaternated"
      start()
    $.Locaternator({
      locations: @testLocations
      currentLocation:
        lat: -35.267852
        lon: 149.124373
      geonames:
        account: "geonamesCredentials.json"
    })


  module "json location data test",

  asyncTest "finds a current location, closest location, and other locations given a json file.", ->
    $(document).on "locaternated", (evt, location, closest, otherLocations) ->
      notEqual evt, null, "expected the event to not be null"
      equal typeof location.latitude, "number", "expected the location's latitude to be a number, not #{typeof location.latitude}"
      notEqual closest.name, "none", "expected the closest location to not be 'none'"
      equal otherLocations.length, 3, "expected the locations array to only have one element"
      console.debug "location", location, "closest", closest, "other locations", otherLocations
      $(document).off "locaternated"
      start()
    $.Locaternator({locations: "locations.json"})
) jQuery
