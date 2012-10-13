
define(["jquery", "lodash", "backbone", "plugins/backbone.layoutmanager"], function($, _, Backbone) {
  var JST, app;
  app = {
    root: "/"
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
  return _.extend(app, {
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
    }
  }, Backbone.Events);
});
