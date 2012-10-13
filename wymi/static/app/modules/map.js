
define(["app", "backbone"], function(app, Backbone) {
  var Map;
  Map = app.module();
  Map.generateMap = function(element, latlng) {
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
  Map.createPin = function(map, latlng, title, content) {
    var poi;
    poi = new MQA.Poi(latlng);
    poi.setInfoTitleHTML(title);
    poi.setInfoContentHTML(content);
    map.addShape(poi);
  };
  return Map;
});
