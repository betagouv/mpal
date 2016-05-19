$(document).ready(function() {
  var mymap = L.map('mapid').setView([45.778878,4.837361], 11);
  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(mymap);

});
