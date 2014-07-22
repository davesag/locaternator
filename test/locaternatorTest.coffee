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

  module "basic tests",
  
  asyncTest "finds a location", ->
    testLocations = [
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
    $(document).on "locaternated", (evt, location, locations, closest) ->
      notEqual evt, null, "expected the event to not be null"
      equal typeof location.latitude, "number", "expected the location's latitude to be a number, not #{typeof location.latitude}"
      equal locations.length, 2, "expected the locations array to be empty"
      notEqual closest.name, "none", "expected the closest location to not be 'none'"
      console.debug closest
      start()
    $.Locaternator({locations: testLocations})
) jQuery
