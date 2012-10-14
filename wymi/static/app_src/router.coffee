define [
  "app"
  "backbone"
  "modules/facility"
], (app, Backbone, Facility) ->
  
  # Defining the application router, you can attach sub routers here.
  Router = Backbone.Router.extend
    routes:
      "": "loadRegion"
      "old": "index"
      "location/:id": "single"

    initialize: () ->
      
      app.regionCollection = new Facility.Collection
      Temp = Facility.LocalCollection.extend
        parent: app.regionCollection
      app.localFacilities = new Temp()
      
      app.on 'regionFileUpdate', (err, file) =>
        app.regionCollection.fetch
          url: file
          success: ->
            app.localFacilities.recalculate()
            # app.localFacilities.trigger('change')
      
      return
    
    loadRegion: () ->
      main = app.useLayout 'index'
      main.setViews
        '.left': new Facility.Views.List
          collection: app.localFacilities
        # '.map': new 
      
      # get region
      if not app.regionFile
        app.fetchRegion()
    
    index: () ->
      app.facilities = new Facility.Collection
      main = app.useLayout 'index'
      console.log app.facilities
      main.setViews
        '.left': new Facility.Views.List
          collection: app.facilities
        # '.map': new 
      
      app.facilities.fetch()
      
    single: (id) ->
      detail = app.useLayout 'detail'
      
      facility = app.facilities.get(id)
      # get facility if none present
      if not facility
        facility = new Facility.Model
          id: id
          
        facility.fetch()
    
      detail.setViews
        '.left': new Facility.Views.Detail
          model: facility


  return Router