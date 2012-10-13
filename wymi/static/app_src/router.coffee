define [
  "app"
  "backbone"
  "modules/facility"
], (app, Backbone, Facility) ->
  
  # Defining the application router, you can attach sub routers here.
  Router = Backbone.Router.extend
    routes:
      "": "index"
      "location/:id": "single"

    initialize: () ->
      app.facilities = new Facility.Collection
      
      app.on 'regionFileUpdate', (err, file) ->
        throw err if err
        app.facilities.fetch
          url: file
      
      return

    index: () ->
      main = app.useLayout 'index'
      console.log app.facilities
      main.setViews
        '.left': new Facility.Views.List
          collection: app.facilities
        # '.map': new 
      
      # get region
      if not app.regionFile
        app.fetchRegion()
      
      # app.facilities.fetch()
      
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