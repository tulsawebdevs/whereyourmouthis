define [
  "app"
  "backbone"
], (app, Backbone) ->

  Facility = app.module()


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
      return "/api/v1/facility/#{@id}?format=json"
    
    parse: (res) ->
      return res


  Facility.Collection = Backbone.Collection.extend
    model: Facility.Model
    
    url: () ->
      return "/api/v1/facility/?format=json&order_by=-latest_score"
    
    parse: (res) ->
      return res.objects


  Facility.Views.ListItem = Backbone.View.extend
    tagName: 'li'
  
    template: 'facilityListItem'
  
    # events: 
    #   "click": "viewDetail"
  
    initialize: () ->
      _.bindAll(@, 'render')
      @model.on 'change', @render
    #   @model.bind('destroy', @remove)
      
    # viewDetail: () ->
      # console.log "viewing detail #{@model.id}"
      
    serialize: () ->
      return {
        fac: @model.toJSON()
        display_address: true
      }
    
    cleanup: ->
      @model.off(null, null, @)


  Facility.Views.List = Backbone.View.extend
    template: 'facilityList'
      
    className: "facility-wrapper",
        
    events:
      "click .refresh": "refreshLocation"
    
    initialize: () ->
      _.bindAll(@, 'render', 'refreshLocation')
      
      # @collection.bind('add', @render)
      @collection.bind('reset', @render)
      @collection.bind('all', @render)
    
      # @refreshLocation()
      return

    serialize: ->
      return {
        count: @collection.length
      }

    beforeRender: () ->
      @collection.each (facility) =>
        @insertView '.facility-list', new Facility.Views.ListItem
          model: facility

    # refreshLocation: () ->
    #   if (navigator.geolocation)
    #     # Geo refresh request
    #     navigator.geolocation.getCurrentPosition (pos) =>
    #       lat = pos.coords.latitude
    #       lon = pos.coords.longitude
    #       # approx. 1/2 mile TODO: if 0 found, try dist = .1
    #       dist = .01
    #       @collection.fetch
    #         data:
    #           near: "#{lat},#{lon},#{dist}"

    cleanup: ->
      @collection.off(null, null, @)


  Facility.Views.Detail = Backbone.View.extend
    tagName: 'div'
  
    className: "facility-detail-wrapper well",
    
    template: 'facilityDetail'
  
    serialize: () ->
      return{
        fac: @model.toJSON()
      }


  return Facility