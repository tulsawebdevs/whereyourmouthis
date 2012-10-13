
define(["jquery", "lodash", "backbone", "plugins/backbone.layoutmanager"], function($, _, Backbone) {
  var JST, app;
  app = {
    api: {
      regionEndPoint: '/region',
      startPoint: '/api/v1/'
    },
    regionFile: null,
    root: "/",
    locationOpt: {
      maximumAge: 60 * 60 * 100,
      timeout: 3000
    }
  };
  JST = window.JST = window.JST || {};
  Backbone.LayoutManager.configure({
    manage: true,
    paths: {
      layout: "static/app/templates/layouts/",
      template: "static/app/templates/"
    },
    fetch: function(path) {
      var done;
      done = void 0;
      path = path + ".html";
      if (JST[path]) {
        return JST[path];
      } else {
        done = this.async();
        return $.ajax({
          url: app.root + path
        }).then(function(contents) {
          return done(JST[path] = _.template(contents));
        });
      }
    }
  });
  _.extend(app, {
    module: function(additionalProps) {
      return _.extend({
        Views: {}
      }, additionalProps);
    },
    useLayout: function(name, options) {
      var layout;
      if (this.layout && this.layout.options.template === name) {
        return this.layout;
      }
      if (this.layout) {
        this.layout.remove();
      }
      layout = new Backbone.Layout(_.extend({
        template: name,
        className: "layout " + name,
        id: "layout"
      }, options));
      $("#main").empty().append(layout.el);
      layout.render();
      this.layout = layout;
      return layout;
    },
    fetchLocation: function() {
      var def;
      def = $.Deferred();
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(pos) {
          return def.resolve(pos);
        }, function(err) {
          return def.reject(err);
        }, this.locationOpt);
      } else {
        console.error('location services not supported in this browser');
        def.reject();
      }
      return def;
    },
    fetchRegion: function() {
      var _this = this;
      return this.fetchLocation().done(function(pos) {
        return $.ajax({
          url: _this.api.regionEndPoint,
          method: 'get',
          data: {
            lat: pos.coords.latitude,
            lng: pos.coords.longitude
          }
        }).error(function(resp, type) {
          return _this.trigger('regionFileUpdate', new Error('unable to retrieve region file location'), _this.regionFile);
        }).success(function(resp) {
          _this.regionFile = resp;
          return _this.trigger('regionFileUpdate', null, resp);
        });
      });
    }
  }, Backbone.Events);
  return app;
});
