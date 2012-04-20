generateMap = (element, latlng) ->
  options = 
    elt:element
    zoom:10
    latLng:latlng
    mtype:'map'
    bestFitMargin:0
    zoomOnDoubleClick:true

  window.map = new MQA.TileMap(options)
  return

createPin = (map, latlng, title, content) ->
  poi = new MQA.Poi(latlng)
  poi.setInfoTitleHTML(title)
  poi.setInfoContentHTML(content)
  map.addShape(poi)
  return
