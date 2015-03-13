# Instagram credentials
#var access_token = "267561381.c183f23.99d014bbeaa9468a9ff487d7c9c64fa6";

# Picture display on the main page
getDataFromInstagram = (instagram_data, appendPhotos) ->
  if instagram_data.meta.code is 200
    console.log('instagram_data.meta.code = ' + instagram_data.meta.code)
    # nextUrl
    if instagram_data.pagination
      if instagram_data.pagination.next_url
        # We don't need access_token in next_url
        # since it's in $.getJSON
        url_formatted = instagram_data.pagination.next_url.replace(/access_token=[^&]+&/, "").replace(/callback=[^&]+/, "callback=?")
        $("button.btn.next").unbind("click").click ->
          $(this).button "loading"
          updatePhotosByTag "tag", url_formatted

    photos = instagram_data.data
    if photos.length > 0
      # Remove previous photos if appendPhotos is not set to true
      $("#photos").empty()  unless appendPhotos is true
      # Set counter to the number of already existing photos
      i = $("#photos .row.pics .col-md-2").length
      for key of photos
        photo = photos[key]
        type = undefined
        if photo.type is "image"
          type = "<div id=\"type\"><i class=\"fa fa-camera-retro\"></i></div>"
        else
          type = "<div id=\"type\"><i class=\"fa fa-film\"></i></div>"
        likes = "<div id=\"likes\"><i class=\"fa fa-heart-o\"></i>" + " " + photo.likes.count + "</div>"
        comments = "<div id=\"comments\"><i class=\"fa fa-comment-o\"></i>" + " " + photo.comments.count + "</div>"
        photoCode = "<div class=\"col-md-2 grid cs-style-3\">" + "<div class=\"thumbnail hover\"><figure>" + "<img class=\"img-" + i + "\" src=\"" + photo.images.thumbnail.url + "\"><figcaption>" + type + likes + comments + "</figcaption></figure></div></div>"
        $("#photos").append "<div class=\"row pics\"></div>"  if Math.round(i / 6) is i / 6
        $("#photos .row").last().append photoCode
        # Thumnail click handler
        $("img.img-" + i).unbind("click").click
          url: photo.images.standard_resolution.url
          width: photo.images.standard_resolution.width
          height: photo.images.standard_resolution.height
          photo: photo
        , (e) ->
          # Remove previous element
          $(".row.pics.tmp").remove()  unless $(".row.pics.tmp").length is 0
          if e.data.photo.type is "image"
            # Choose image link
            # Try high, standard and low
            if e.data.photo.images.high_resolution
              link = e.data.photo.images.high_resolution.url
            else if e.data.photo.images.standard_resolution
              link = e.data.photo.images.standard_resolution.url
            else
              link = e.data.photo.images.low_resolution.url
            code = "<div class=\"row pics tmp\">" + "<div class=\"col-md-8 text-center\">" + "<img class=\"img-thumbnail tmp\" src=" + link + " alt=\"...\">" + "</div>" + "</div>"
          else
            # Choose video link
            # Try high, standard and low
            if e.data.photo.videos.high_resolution
              link = e.data.photo.videos.high_resolution.url
            else if e.data.photo.videos.standard_resolution
              link = e.data.photo.videos.standard_resolution.url
            else
              link = e.data.photo.videos.low_resolution.url
            # Code for enlarged image
            code = "<div class=\"row pics tmp\">" + "<div class=\"col-md-8 text-center\">" + "<video class=\"img-thumbnail tmp\" controls autoplay loop>" + "<source src=" + link + ">" + "</video>" + "</div>" + "</div>"
          # Append enlarged image code
          $(code).insertAfter $(this).parent().parent().parent().parent()
          # Description for enlarged image
          description = "<div class=\"col-md4\">" + "<p><a href=\"" + e.data.photo.link + "\"><h1>" + e.data.photo.user.username + "</h1></a></p>" + "<img class=\"img-thumbnail\" src=\"" + e.data.photo.user.profile_picture + "\">" + "</div>"
          # Animate thumbnail click
          $("img.img-thumbnail.tmp, video.img-thumbnail.tmp").animate
            width: e.data.width
            height: e.data.height
          , 500, ->
            $(this).parent().after description


        # .click
        i++
    else
      $("#status").text "Hmm. I couldn’t find anything!"
    $("#searchButtonGeo").button "reset"
    $("#searchButtonTag").button "reset"
    $("button.btn.next").button "reset"
  # else
    # error = instagram_data.meta.error_message
    # if error == "Missing client_id or access_token URL parameter."
    #   $("#status").text "Please sign in"
    # else
    # $("#status").text "Instagram error: " + error

# Add "Enter" and click handers.

# Click handler
# Geo

# Tag

# Enter handler
# Geo

# Do not update page

# Tag

# Do not update page

# Take address from url
# or from browser built-in location function
initialUpdate = ->
  showPosition = (position) ->
    userLat = position.coords.latitude
    userLng = position.coords.longitude

    # Send coordinates to Google API to get an actual address
    coordsToAddr userLat, userLng
    updateByCoords userLat, userLng
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition showPosition
  else
    $("#status").text "Geolocation is not supported by this browser."

# Get coords from adddress using google api
# update maps
# update url
# update status
# update photos
updateByAddr = (address) ->
  geocoder = new google.maps.Geocoder()
  geocoder.geocode
    address: address
  , (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      # Update status
      $("#status").text results[0].formatted_address
      # Update url
      addrToUrl results[0].formatted_address
      # Get location
      res = results[0].geometry.location
      # Update google maps with current location
      #and put marker into the right place
      initializeMaps res.lat(), res.lng()
      # Update instagram pictures
      updatePhotosByCoords res.lat(), res.lng()
      getPopularLocations res.lat(), res.lng()
    else
      $("#status").text "Geocode was not successful for the following reason: " + status

# Using coords and google api
# 1. Update status
# 2. Add address to url
coordsToAddr = (lat, lng) ->
  geocoder = new google.maps.Geocoder()
  latlng = new google.maps.LatLng(lat, lng)
  geocoder.geocode
    latLng: latlng
  , (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      if results[1]
        # Update status with address
        $("#status").text results[1].formatted_address
        # Add address to url
        addrToUrl results[1].formatted_address
    else
      $("#status").text "Geocoder failed due to: " + status


# GEO coordinates
updateByCoords = (lat, lng) ->
  # Update google maps with current location
  #and put marker into the right place
  initializeMaps lat, lng
  # Update instagram pictures
  updatePhotosByCoords lat, lng
updatePhotosByCoords = (lat, lng) ->
  console.log('updatePhotosByCoords')
  instagramUrl = "https://api.instagram.com/v1/media/search?lat=" + lat + "&lng=" + lng + "&distance=" + 50 + "&callback=?"
  $.getJSON instagramUrl, access_parameters, getDataFromInstagram
updatePhotosByTag = (tag, nextUrl) ->
  instagramUrl = "https://api.instagram.com/v1/tags/" + tag + "/media/recent" + "?count=" + count + "&callback=?"
  if nextUrl
    appendPhotos = true
    $.getJSON nextUrl, access_parameters, (instagram_data) ->
      getDataFromInstagram instagram_data, true

  else
    $.getJSON instagramUrl, access_parameters, getDataFromInstagram
    tagToUrl tag

#Show Popular Locations
getPopularLocations = (lat, lng) ->
  foursquareUrl = "https://api.foursquare.com/v2/venues/explore?ll=" + lat + "," + lng + "&oauth_token=BUGNB0B2ML1KT4HDKWGI1MECXSKJDRJDO21QNZZLRRGEVYQQ&v=20140509" + "&venuePhotos=1"
  $.getJSON foursquareUrl, getDataFromFoursquareForLocation
getDataFromFoursquareForLocation = (foursquare_data) ->
  if foursquare_data.meta.code is 200
    locations = foursquare_data.response.groups[0].items
    console.log('foursquare_data.response.groups[0].items = ' + "'" + foursquare_data.response.groups[0].items.length + "'")
    $("#popularLoc").empty()
    if foursquare_data.response.groups[0].items.length != 0
      i = 0
      while i < 5
        lat = locations[i].venue.location.lat
        lng = locations[i].venue.location.lng
        popular = "<button type=\"button\" class=\"btn button-popularLoc btn-default btn-xs btn-popular-" + i + "\">" + locations[i].venue.name + "</button>"
        $("#popularLoc").append popular
        $(".btn-popular-" + i).unbind("click").click
          lat: lat
          lng: lng
        , (e) ->
          # Update url
          updateByCoords e.data.lat, e.data.lng
          coordsToAddr e.data.lat, e.data.lng
        i++
  else
    error = foursquare_data.meta.errorDetail
    $("#status").text "Something happened, Foursquare said: " + error

#Show Popular Tag
displayPopularTag = ->
  $("#popularTag").empty()
  tags = [ "love", "tbt", "cute", "happy", "beautiful", "fun", "food", "art", "best", "day", "nature" ]
  i = 0

  while i < tags.length
    tagName = tags[i]
    popularTags = "<button type=\"button\" class=\"btn button-popular-tag btn-default btn-sm btn-popular-tag-" + i + "\">" + tagName + "</button>"
    $("#popularTag").append popularTags
    $(".btn-popular-tag-" + i).unbind("click").click
      tag: tagName
    , (e) ->
      updatePhotosByTag e.data.tag

    i++

# instaAuthorized
instaAuthorized = ->
  if $.cookie("insta_token")
    $("#auth").css "display", "none"
    $("#notauth").removeAttr "style"
  else
    $("#auth").removeAttr "style"
    $("#notauth").css "display", "none"
access_token = $.cookie("insta_token")
access_parameters = access_token: access_token
distance = 5000
count = 24

$(document).ready ->
  if window.location.href.match(/#access_token=.+/)
    str = window.location.href.match(/#access_token=.+/)
    res = str[0].replace("#access_token=", "")
    $.cookie "insta_token", res,
      expires: 7
      path: "/"

  instaAuthorized()
  if window.location.href.match(/#addr-.+/)
    addr = window.location.href.match(/#.+/)[0].replace(/#addr-/, "").replace(/-/g, " ")
    updateByAddr addr
  else if window.location.href.match(/#tag-.+/)
    tag = window.location.href.match(/#.+/)[0].replace(/#tag-/, "")
    updatePhotosByTag tag
    unless $("#tagButton").attr("class").match(/active$/)
      $("#tagButton").addClass "active btn-tag"
      $("#geoButton").removeClass "active btn-geo"
      $("#geoButton").addClass "btn-default btn-geo-hover"
      $("#map-canvas").css "display", "none"
      $("#formGeo").css "display", "none"
      $("#formTag").removeAttr "style"
      $("#popularTag").removeAttr "style"
      $("#buttonMore").removeAttr "style"
      $("#status").text "Search by tag"
      $(".block_second").css "border-color", "#FFA500"
      $(".popularLocTitle").css "display", "none"
      displayPopularTag()
  else
    initialUpdate()  if $("#geoButton").attr("class").match(/active$/)
  $("#geoButton").unbind("click").click ->
    unless $(this).attr("class").match(/active$/)
      $(this).addClass "active btn-geo"
      $("#geoButton").removeClass "btn-default"
      $("#tagButton").removeClass "active btn-tag"
      $("#tagButton").addClass "btn-default btn-tag-hover"
      $("#map-canvas").css "display", ""
      $("#formTag").css "display", "none"
      $("#formGeo").removeAttr "style"
      $("#popularTag").css "display", "none"
      $("#popularLoc").removeAttr "style"
      $(".popularLocTitle").removeAttr "style"
      $("#tagButton").removeClass "active btn-primary"
      $("#buttonMore").css "display", "none"
      $("#status").text "Search by location"
      $(".block_second").css "border-color", "#FF6347"

  $("#tagButton").unbind("click").click ->
    unless $(this).attr("class").match(/active$/)
      $(this).addClass "active btn-tag"
      $("#geoButton").removeClass "active btn-geo"
      $("#geoButton").addClass "btn-default btn-geo-hover"
      $("#map-canvas").css "display", "none"
      $("#formGeo").css "display", "none"
      $("#formTag").removeAttr "style"
      $("#popularLoc").css "display", "none"
      $("#popularTag").removeAttr "style"
      $("#status").text "Search by tag"
      $("#buttonMore").removeAttr "style"
      $(".block_second").css "border-color", "#FFA500"
      $(".popularLocTitle").css "display", "none"
      displayPopularTag()


$(document).ready ->
  $("#searchButtonGeo").unbind("click").click ->
    $(this).button "loading"
    updateByAddr $("#searchTextGeo").val()


  $("#searchButtonTag").unbind("click").click ->
    $(this).button "loading"
    updatePhotosByTag $("#searchTextTag").val()
    $("#status").text "Searching by tag: \"" + $("#searchTextTag").val() + "\""

  $("#searchTextGeo").bind "keypress", (e) ->
    code = e.keyCode or e.which
    if code is 13
      $("#searchButtonGeo").button "loading"
      updateByAddr $("#searchTextGeo").val()
      e.preventDefault()
      false

  $("#searchTextTag").bind "keypress", (e) ->
    code = e.keyCode or e.which
    if code is 13
      $("#searchButtonTag").button "loading"
      updatePhotosByTag $("#searchTextTag").val()
      $("#status").text "Searching by tag: \"" + $("#searchTextTag").val() + "\""
      e.preventDefault()
      false

#Delete cookie
$(document).ready ->

  # Click Not auth
  $("#notauth").unbind("click").click ->
    $.removeCookie "insta_token"
    location.reload()

