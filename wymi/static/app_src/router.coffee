define [
  "app"
  "backbone"
], (app, Backbone) ->
  
  # Defining the application router, you can attach sub routers here.
  Router = Backbone.Router.extend
    routes:
      "": "index"
    
    index: ->
      console.log('got here, really')
      
  return Router