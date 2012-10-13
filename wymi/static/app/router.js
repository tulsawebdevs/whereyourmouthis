
define(["app", "backbone", "modules/facility"], function(app, Backbone, Facility) {
  var Router;
  Router = Backbone.Router.extend({
    routes: {
      "": "index",
      "location/:id": "single"
    },
    initialize: function() {
      app.facilities = new Facility.Collection;
      app.facilities.fetch();
    },
    index: function() {
      var main;
      main = app.useLayout('index');
      return main.setViews({
        '.left': new Facility.Views.List({
          collection: app.facilities
        })
      });
    },
    single: function(id) {
      var detail, facility;
      detail = app.useLayout('detail');
      facility = app.facilities.get(id);
      return detail.setViews({
        '.left': new Facility.Views.Detail({
          model: facility
        })
      });
    }
  });
  return Router;
});
