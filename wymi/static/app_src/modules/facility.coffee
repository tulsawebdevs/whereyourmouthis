define [
  "app"
  "backbone"
  "plugins/backbone.subset"
], (app, Backbone) ->

  Facility = app.module()


  Facility.Model = Backbone.Model.extend
    defaults:
      address: 'nowhere'
      city: 'someplace'
      state: 'Not OK'
      distance: null
      name: ''
      type: ''
      latest_score: 50
      display_address: ''
      "address": ''
      zip_code: ''
    
    # initialize: () ->
    
    url: () ->
      return "#{app.api.startPoint}facility/#{@id}/?format=json"
    
    parse: (res) ->
      return res
    
    getDistance: (pos) ->
      # pulled from okletsgo
      R = 3961 # miles
      lat1 = parseInt @get('lat')
      lng1 = parseInt @get('lng')
      lat2 = pos.coords.latitude
      lng2 = pos.coords.longitude
      
      dLat = (lat2-lat1) * Math.PI / 180
      dlng = (lng2-lng1) * Math.PI / 180
      lat1 = lat1 * Math.PI / 180
      lat2 = lat2 * Math.PI / 180

      a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.sin(dlng/2) * Math.sin(dlng/2) * Math.cos(lat1) * Math.cos(lat2)

      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      dist = R * c
      @set('distance', Math.floor(dist), {silent: true})
      return dist


  Facility.Collection = Backbone.Collection.extend
    model: Facility.Model
    
    # initialize: () ->
    #   console.log 'init collection'
    
    url: () ->
      return "#{app.api.startPoint}facility/?format=json&order_by=-latest_score"
    
    parse: (res) ->
      return res.objects


  Facility.LocalCollection = Backbone.Subset.extend
    # initilize: (options) ->
      
    sieve: (facility) ->
      dist = facility.getDistance(app.curPos)
      return dist <= app.localDist

  Facility.Views.ListItem = Backbone.View.extend
    tagName: 'li'
  
    template: 'facilityListItem'
  
    initialize: () ->
      _.bindAll(@, 'render', 'remove')
      
      @model.on 'change', @render
      @model.on 'destroy', @remove
      
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
      @collection.bind('change', @render)
      # @collection.bind('all', @render)
    
      # @refreshLocation()
      return

    serialize: ->
      return {
        count: @collection.length
      }

    beforeRender: () ->
      if @collection
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