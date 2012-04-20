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
window.wymi = {}

Facility =
  Views: {}
  Model: null
  Collection: null
  
Facility.Views.ListItem = Backbone.View.extend
  tagName: 'li'
  
  template: '#facilityListItem'
  
  # events: 
  #   "click": "viewDetail"
  
  # initialize: () ->
  #   _.bindAll(@, 'render', 'remove')
  #   @model.bind('change', @render)
  #   @model.bind('destroy', @remove)
      
  # viewDetail: () ->
    # console.log "viewing detail #{@model.id}"
      
  serialize: () ->
    return {
      fac: @model.toJSON()
      display_address: true
    }
                
Facility.Views.List = Backbone.View.extend
  template: '#facilityList'
      
  className: "facility-wrapper",
        
  events:
    "click .refresh": "refreshLocation"
    
  initialize: () ->
    # _.bindAll @, 'addOne', 'addAll', 'render', 'refreshLocation'
    
    @collection.bind('add', () ->
      @render()
    , @)
    @collection.bind('reset', () ->
      @render()
    , @)
    @collection.bind('all', () ->
      @render()
    , @)
    
    # @collection.reset(data)
    
    @refreshLocation()
    return
      
  render: (layout) ->
    view = layout(@)
    @addAll(view)
    view.render
      count: @collection.length
        
  addOne: (view) ->
    return (facility) ->
      console.log "adding #{facility.get('name')}"
      view.insert '.facility-list', new Facility.Views.ListItem
        model: facility
    
  addAll: (view) ->
    # remove all existing facilities
    @collection.each(@addOne(view))
  
  refreshLocation: () ->
    if (navigator.geolocation)
      # Geo refresh request
      navigator.geolocation.getCurrentPosition (pos) =>
        @collection.fetch
          data:
            lat: pos.coords.latitude
            lon: pos.coords.longitude
    
Facility.Views.Detail = Backbone.View.extend
  tagName: 'div'
  
  className: "facility-detail-wrapper well",
    
  template: '#facilityDetail'
  
  serialize: () ->
    return{
      fac: @model.toJSON()
    }
        
Facility.Model = Backbone.Model.extend
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
    
Facility.Collection = Backbone.Collection.extend
  model: Facility.Model
    
  url: () ->
    # Change url based on location
    # http://whereyourmouth.is/api/v1/facility/?format=json
    return "/api/v1/facility/"
    
  parse: (res) ->
    return res.objects
    
# wymo.views.map = Backbone.View.extend
#   tagName: 'div'
#   
#   template: _.template($('#mapTemplate').html())
#   
#   events:
#     "click .zoomP": 'zoomIn'
#     "click .zoomM": 'zoomOut'
#   
#   initialize: () ->
#     _.bindAll(@,'render')
#     
#   render: () ->
#     $(@el).html @template
#       fac: @model.toJSON()
#     return @

  # initialLoadMap: () ->
  #   window.map = MQA.TileMap(
  #     $("#map")
  #     18
  #     loc = 
  #       lat:39.743943 
  #       lng:-105.020089
  #     'map'
  #   )
  #   return

Router = Backbone.Router.extend
  currentLayout: null
  
  useLayout: (name) ->
    currentLayout = @currentLayout;

    # If there is an existing layout and its the current one, return it.
    if (currentLayout?.options.template == name) 
      return currentLayout;
    
    # Create the new layout and set it as current.
    return @currentLayout = new Backbone.LayoutManager
      template: name
    
  initialize: () ->
    wymi.facilities = new Facility.Collection
    wymi.facilities.reset(data)
    return
    
  routes:
    "": "index"
    "location/:id": "single"
    
  index: () ->
    console.log 'index'
    main = @useLayout '#index'
    
    main.setViews
      '.left': new Facility.Views.List
        collection: wymi.facilities
      # '.map': new 
  
    main.render (el) ->
      $('#main').html(el)
      
  single: (id) ->
    console.log 'detail view'
    detail = @useLayout '#detail'
    
    facility = wymi.facilities.get(id)
    
    detail.setViews
      '.left': new Facility.Views.Detail
        model: facility
    
    detail.render (el) ->
      $('#main').html(el)

wymi.router = new Router()

Backbone.history.start
  pushState: true

$('body').delegate 'a[data-navigate]','click', (e) ->
  console.log 'navin'
  
  href = $(this).attr('href')
  protocol = @protocol + "//"
  
  if href.slice(0,protocol.length) != protocol
    console.log href
    e.preventDefault()
    wymi.router.navigate(href,true)
    return

console.log 'starting app'
# wymi.app = new App()
