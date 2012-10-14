
define(["app", "backbone", "modules/facility"], function(app, Backbone, Facility) {
  var Router;
  Router = Backbone.Router.extend({
    routes: {
      "": "loadRegion",
      "old": "index",
      "location/:id": "single"
    },
    initialize: function() {
      var Temp,
        _this = this;
      app.regionCollection = new Facility.Collection;
      Temp = Facility.LocalCollection.extend({
        parent: app.regionCollection
      });
      app.localFacilities = new Temp();
      app.on('regionFileUpdate', function(err, file) {
        return app.regionCollection.fetch({
          url: file,
          success: function() {
            return app.localFacilities.recalculate();
          }
        });
      });
    },
    loadRegion: function() {
      var main;
      main = app.useLayout('index');
      main.setViews({
        '.left': new Facility.Views.List({
          collection: app.localFacilities
        })
      });
      if (!app.regionFile) {
        return app.fetchRegion();
      }
    },
    index: function() {
      var main;
      app.facilities = new Facility.Collection;
      main = app.useLayout('index');
      console.log(app.facilities);
      main.setViews({
        '.left': new Facility.Views.List({
          collection: app.facilities
        })
      });
      return app.facilities.fetch();
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
