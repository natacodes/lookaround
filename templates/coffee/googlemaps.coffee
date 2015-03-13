$(document).ready ->
  initializeMaps(34.07, -17.11, 2)

window.markers = []

placeMarker = (position, map) ->
  marker = new google.maps.Marker(
    position: position
    map: map
  )
  i = 0

  while i < @window.markers.length
    window.markers[i].setMap null
    i++
  window.markers = []
  map.panTo position
  window.markers.push marker
initializeMaps = (userLat, userLng, zoom) ->
  zoom = 14 if typeof(zoom) == 'undefined'
  mapOptions =
    zoom: zoom
    center: new google.maps.LatLng(userLat, userLng)
    streetViewControl: false
    zoomControl: true
    zoomControlOptions:
      style: google.maps.ZoomControlStyle.LARGE
      position: google.maps.ControlPosition.LEFT_CENTER

  console.log("mapOptions = " + mapOptions['zoomControl'])

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

  # map.setCenter(new google.maps.LatLng(userLat, userLng));
  input = document.getElementById("searchTextGeo")
  autocomplete = new google.maps.places.Autocomplete(input)
  autocomplete.bindTo "bounds", map

  #var infowindow = new google.maps.InfoWindow();

  # Create initial marker
  placeMarker new google.maps.LatLng(userLat, userLng), map
  google.maps.event.addListener autocomplete, "place_changed", ->

    #infowindow.close();
    marker = window.markers[0]
    marker.setVisible false
    place = autocomplete.getPlace()
    return  unless place.geometry

    # If the place has a geometry, then present it on a map.
    if place.geometry.viewport
      map.fitBounds place.geometry.viewport
    else
      map.setCenter place.geometry.location
      map.setZoom 17 # Why 17? Because it looks good.

    # marker.setIcon(/** @type {google.maps.Icon} */({
    #   url: place.icon,
    #   size: new google.maps.Size(71, 71),
    #   origin: new google.maps.Point(0, 0),
    #   anchor: new google.maps.Point(17, 34),
    #   scaledSize: new google.maps.Size(35, 35)
    # }));
    marker.setPosition place.geometry.location
    marker.setVisible true
    address = ""
    address = [ (place.address_components[0] and place.address_components[0].short_name or ""), (place.address_components[1] and place.address_components[1].short_name or ""), (place.address_components[2] and place.address_components[2].short_name or "") ].join(" ")  if place.address_components


  # infowindow.setContent('<div><strong>' +
  #   place.name + '</strong><br>' + address);
  # infowindow.open(map, marker);

  # Click placeMarker start
  google.maps.event.addListener map, "click", (e) ->
    # Place marker on map
    placeMarker e.latLng, map
    # Update status
    coordsToAddr e.latLng.lat(), e.latLng.lng()
    getPopularLocations e.latLng.lat(), e.latLng.lng()
    # Update photos
    instagramUrl = "https://api.instagram.com/v1/media/search?lat=" + e.latLng.lat() + "&lng=" + e.latLng.lng() + "&callback=?"
    $.getJSON instagramUrl, access_parameters, getDataFromInstagram
