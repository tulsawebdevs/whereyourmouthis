
define(["app", "backbone", "modules/facility"], function(app, Backbone, Facility) {
  var Router;
  Router = Backbone.Router.extend({
    routes: {
      "": "index",
      "location/:id": "single"
    },
    initialize: function() {
      app.facilities = new Facility.Collection;
      app.on('regionFileUpdate', function(err, file) {
        if (err) {
          throw err;
        }
        return app.facilities.fetch({
          url: file
        });
      });
    },
    index: function() {
      var main;
      main = app.useLayout('index');
      console.log(app.facilities);
      main.setViews({
        '.left': new Facility.Views.List({
          collection: app.facilities
        })
      });
      if (!app.regionFile) {
        return app.fetchRegion();
      }
    },
    single: function(id) {
      var detail, facility;
      detail = app.useLayout('detail');
      facility = app.facilities.get(id);
      if (!facility) {
        facility = new Facility.Model({
          id: id
        });
        facility.fetch();
      }
      return detail.setViews({
        '.left': new Facility.Views.Detail({
          model: facility
        })
      });
    }
  });
  return Router;
});
