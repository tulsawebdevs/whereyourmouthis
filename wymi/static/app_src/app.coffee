define [
  # Libraries.
  "jquery"
  "lodash"
  "backbone"
  # Plugins.
  "plugins/backbone.layoutmanager"
], ($, _, Backbone) ->
  
  # Provide a global location to place configuration settings and module
  # creation.
  
  # The root path to run the application.
  app =
    api:
      regionEndPoint: '/region'
      startPoint: '/api/v1/'
    regionFile: null
    root: "/"
    locationOpt:
      maximumAge: 60 * 60 * 100
      timeout: 3000
  
  # Localize or create a new JavaScript Template object.
  JST = window.JST = window.JST or {}
  
  # Configure LayoutManager with Backbone Boilerplate defaults.
  Backbone.LayoutManager.configure
    
    # Allow LayoutManager to augment Backbone.View.prototype.
    manage: true
    paths:
      layout: "static/app/templates/layouts/"
      template: "static/app/templates/"

    fetch: (path) ->
      
      # Initialize done for use in async-mode
      done = undefined
      
      # Concatenate the file extension.
      path = path + ".html"
      
      # If cached, use the compiled template.
      if JST[path]
        JST[path]
      else
        
        # Put fetch into `async-mode`.
        done = @async()
        
        # Seek out the template asynchronously.
        $.ajax(url: app.root + path).then (contents) ->
          done JST[path] = _.template(contents)

  
  # Mix Backbone.Events, modules, and layout management into the app object.
  _.extend app,
    
    # Create a custom object with a nested Views object.
    module: (additionalProps) ->
      return _.extend
        Views: {}
      , additionalProps

    
    # Helper for using layouts.
    useLayout: (name, options) ->
      
      # If already using this Layout, then don't re-inject into the DOM.
      return @layout  if @layout and @layout.options.template is name
      
      # If a layout already exists, remove it from the DOM.
      @layout.remove()  if @layout
      
      # Create a new Layout with options.
      layout = new Backbone.Layout(_.extend(
        template: name
        className: "layout #{name}"
        id: "layout"
      , options))
      
      # Insert into the DOM.
      $("#main").empty().append layout.el
      
      # Render the layout.
      layout.render()
      
      # Cache the refererence.
      @layout = layout
      
      # Return the reference, for chainability.
      return layout
    
    fetchLocation: ->
      def = $.Deferred()
      # MAYBE: popup confirmation dialog explaining why we need their location?
      if (navigator.geolocation)
        navigator.geolocation.getCurrentPosition (pos) ->
          def.resolve(pos)
        , (err) ->
          # TODO: this doesn't fire when you cancel the location lookup
          # probably only on a gps/location lookup error, :(
          def.reject(err)
        , @locationOpt
      else
        console.error 'location services not supported in this browser'
        def.reject()
      
      return def
        
    fetchRegion: ->
      @fetchLocation().done (pos) =>
        
        $.ajax(
          url: @api.regionEndPoint
          method: 'get'
          data:
            lat: pos.coords.latitude
            lng: pos.coords.longitude
        ).error( (resp, type) =>
          @trigger 'regionFileUpdate', new Error('unable to retrieve region file location'), @regionFile
        ).success( (resp) =>
          @regionFile = resp
          @trigger 'regionFileUpdate', null, resp
        )
      
  , Backbone.Events

  return app