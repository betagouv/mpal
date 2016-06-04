$(document).ready(function() {
  if ($("#mapid").length) {
//    var mymap = L.map('mapid').setView([45.778878,4.837361], 11);
    coord = { 'lat': gon.latitude, lng: gon.longitude };
    var mymap = L.map('mapid').setView([coord.lat, coord.lng], 16);
    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(mymap);
    L.marker([coord.lat, coord.lng]).addTo(mymap);
  }

});
