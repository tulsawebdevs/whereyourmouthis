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
      return "#{app.api.startPoint}facility/#{@id}/?format=json"
    
    parse: (res) ->
      return res


  Facility.Collection = Backbone.Collection.extend
    model: Facility.Model
    
    url: () ->
      return "#{app.api.startPoint}facility/?format=json&order_by=-latest_score"
    
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
      # @collection.bind('all', @render)
    
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
    
    # afterRender: () ->
      # @$el.find('.refresh').button('loading');
      
    refreshLocation: () ->
      app.fetchLocation().done (pos) =>
        # approx. 1/2 mile TODO: if 0 found, try dist = .1
        dist = .01
        @collection.fetch
          data:
            near: "#{pos.coords.latitude},#{pos.coords.longitude},#{dist}"

    cleanup: ->
      @collection.off(null, null, @)


  Facility.Views.Detail = Backbone.View.extend
    tagName: 'div'
  
    className: "facility-detail-wrapper well",
    
    template: 'facilityDetail'
    
    initialize: () ->
      _.bindAll(@, 'render')
      
      @model.bind('reset', @render)
      @model.bind('change', @render)
  
    serialize: () ->
      return{
        fac: @model.toJSON()
      }


  return Facility