// Generated by CoffeeScript 1.7.1
var initializeMaps, placeMarker;

$(document).ready(function() {
  return initializeMaps(34.07, -17.11, 2);
});

window.markers = [];

placeMarker = function(position, map) {
  var i, marker;
  marker = new google.maps.Marker({
    position: position,
    map: map
  });
  i = 0;
  while (i < this.window.markers.length) {
    window.markers[i].setMap(null);
    i++;
  }
  window.markers = [];
  map.panTo(position);
  return window.markers.push(marker);
};

initializeMaps = function(userLat, userLng, zoom) {
  var autocomplete, input, map, mapOptions;
  if (typeof zoom === 'undefined') {
    zoom = 14;
  }
  mapOptions = {
    zoom: zoom,
    center: new google.maps.LatLng(userLat, userLng),
    streetViewControl: false,
    zoomControl: true,
    zoomControlOptions: {
      style: google.maps.ZoomControlStyle.LARGE,
      position: google.maps.ControlPosition.LEFT_CENTER
    }
  };
  console.log("mapOptions = " + mapOptions['zoomControl']);
  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
  input = document.getElementById("searchTextGeo");
  autocomplete = new google.maps.places.Autocomplete(input);
  autocomplete.bindTo("bounds", map);
  placeMarker(new google.maps.LatLng(userLat, userLng), map);
  google.maps.event.addListener(autocomplete, "place_changed", function() {
    var address, marker, place;
    marker = window.markers[0];
    marker.setVisible(false);
    place = autocomplete.getPlace();
    if (!place.geometry) {
      return;
    }
    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(17);
    }
    marker.setPosition(place.geometry.location);
    marker.setVisible(true);
    address = "";
    if (place.address_components) {
      return address = [place.address_components[0] && place.address_components[0].short_name || "", place.address_components[1] && place.address_components[1].short_name || "", place.address_components[2] && place.address_components[2].short_name || ""].join(" ");
    }
  });
  return google.maps.event.addListener(map, "click", function(e) {
    var instagramUrl;
    placeMarker(e.latLng, map);
    coordsToAddr(e.latLng.lat(), e.latLng.lng());
    getPopularLocations(e.latLng.lat(), e.latLng.lng());
    instagramUrl = "https://api.instagram.com/v1/media/search?lat=" + e.latLng.lat() + "&lng=" + e.latLng.lng() + "&callback=?";
    return $.getJSON(instagramUrl, access_parameters, getDataFromInstagram);
  });
};
