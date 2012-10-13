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
      # TODO: bootstrap with reset when I figure out how
      app.facilities.fetch()
      
      return

    index: () ->
      main = app.useLayout 'index'
    
      main.setViews
        '.left': new Facility.Views.List
          collection: app.facilities
        # '.map': new 

    single: (id) ->
      detail = app.useLayout 'detail'
      
      facility = app.facilities.get(id)
    
      detail.setViews
        '.left': new Facility.Views.Detail
          model: facility


  return Router