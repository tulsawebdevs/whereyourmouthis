# test data
data = [
  {
    "address": "6119 E 11TH ST E TULSA, OK 74112"
    "city": "Tulsa"
    "id": "207"
    "latest_score": 100
    "latitude": "36.14790800"
    "longitude": "-95.90880800"
    "name": "11TH STREET PUB"
    "resource_uri": "/api/v1/facility/208/"
    "state": "OK"
    "type": "Bar"
    "zip_code": "747"
  }
  {
    "address": "6119 E 11TH ST E TULSA, OK 74112"
    "city": "Tulsa"
    "id": "208"
    "latest_score": 70
    "latitude": "36.14790800"
    "longitude": "-95.90880800"
    "name": "11TH STREET PUB"
    "resource_uri": "/api/v1/facility/208/"
    "state": "OK"
    "type": "Bar"
    "zip_code": "456"
  }
  {
    "address": "6119 E 11TH ST E TULSA, OK 74112"
    "city": "Tulsa"
    "id": "209"
    "latest_score": 20
    "latitude": "36.14790800"
    "longitude": "-95.90880800"
    "name": "11TH STREET PUB"
    "resource_uri": "/api/v1/facility/208/"
    "state": "OK"
    "type": "Bar"
    "zip_code": "583"
  }
]

# skeleton
window.wymi=
  views: {}
  collections: {}
  models: {}


# Facility Model
wymi.models.facility = Backbone.Model.extend
  defaults:
    address: 'nowhere'
    city: 'someplace'
    state: 'Not OK'
    latitude: ''
    longitude: ''
    distance: null
    name: ''
    type: ''
    latest_score: 50
    display_address: ''
    "address": ''
    zip_code: ''
    
  initialize: () ->
    
  url: () ->
    return "/api/v1/facility/#{@id}"
    
  parse: (res) ->
    return res.objects[0]
    

# Facility Detail View
wymi.views.facilityDetail = Backbone.View.extend
  tagName: 'div'

  template: _.template($('#facilityDetail').html())
    
  render: () ->
    $(@el).html @template(@model.toJSON())
    return @

# Facility Collection
wymi.collections.facilities = Backbone.Collection.extend
  model: wymi.models.facility
  
  url: () ->
    # Change url based on location
    return "/api/v1/facility/"
    
  parse: (res) ->
    return res.objects
    
# Facility List item
wymi.views.facilityListItem = Backbone.View.extend
  tagName: 'li'
  
  template: _.template($('#facilityListItem').html())
  
  events: 
    "click": "viewDetail"
  
  initialize: () ->
    _.bindAll(@, 'render', 'remove')
    @model.bind('change', @render)
    @model.bind('destroy', @remove)
    
  viewDetail: () ->
    console.log "viewing detail #{@model.id}"
    $('#detail').append(view.render().el)
    
  render: () ->
    $(@el).html @template
      fac: @model.toJSON()
      display_address: @display
    return @
    

App = Backbone.View.extend
  el: $("#appview")
  
  events:
    "click #refreshLoc": "refreshLocation"
    
  initialize: () ->
    _.bindAll @, 'addOne', 'addAll', 'render', 'refreshLocation'
    
    @Facilities = new wymi.collections.facilities
    @Facilities.bind('add', @addOne)
    @Facilities.bind('reset', @addAll);
    @Facilities.bind('all', @render)
    
    @Facilities.reset(data)
    
    @refreshLocation()
    @initialLoadMap()
    return
    
  addOne: (facility) ->
    console.log "adding #{facility.get('name')}"
    
    view = new wymi.views.facilityListItem
      model: facility
    
    @.$('#facility-list').append(view.render().el)
    
  addAll: () ->
    # remove all existing facilities
    @.$('#facility-list').empty()
    @Facilities.each(@.addOne)
  
  refreshLocation: () ->
    if (navigator.geolocation)
      # Geo refresh request
      navigator.geolocation.getCurrentPosition (pos) =>
        @Facilities.fetch
          data:
            lat: pos.coords.latitude
            lon: pos.coords.longitude

  initialLoadMap: () ->
    window.map = MQA.TileMap(
      $("#map")
      18
      loc = 
        lat:39.743943 
        lng:-105.020089
      'map'
    )
    return



console.log 'starting app'
wymi.app = new App()
