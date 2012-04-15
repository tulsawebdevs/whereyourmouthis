(function() {
  var createPin, generateMap;

  generateMap = function(element, latlng) {
    var options;
    options = {
      elt: element,
      zoom: 10,
      latLng: latlng,
      mtype: 'map',
      bestFitMargin: 0,
      zoomOnDoubleClick: true
    };
    window.map = new MQA.TileMap(options);
  };

  createPin = function(map, latlng, title, content) {
    var poi;
    poi = new MQA.Poi(latlng);
    poi.setInfoTitleHTML(title);
    poi.setInfoContentHTML(content);
    map.addShape(poi);
  };

  $(document).ready(function() {
    generateMap(document.getElementById("map"), {
      lat: 36.131389,
      lng: -95.937222
    });
  });

}).call(this);
