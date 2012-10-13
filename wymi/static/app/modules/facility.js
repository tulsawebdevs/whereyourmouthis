
define(["app", "backbone"], function(app, Backbone) {
  var Facility;
  Facility = app.module();
  Facility.Model = Backbone.Model.extend({
    defaults: {
      address: 'nowhere',
      city: 'someplace',
      state: 'Not OK',
      latitude: '',
      longitude: '',
      distance: null,
      name: '',
      type: '',
      latest_score: 50,
      display_address: '',
      "address": '',
      zip_code: ''
    },
    initialize: function() {},
    url: function() {
      return "" + app.api.startPoint + "facility/" + this.id + "/?format=json";
    },
    parse: function(res) {
      return res;
    }
  });
  Facility.Collection = Backbone.Collection.extend({
    model: Facility.Model,
    url: function() {
      return "" + app.api.startPoint + "facility/?format=json&order_by=-latest_score";
    },
    parse: function(res) {
      return res.objects;
    }
  });
  Facility.Views.ListItem = Backbone.View.extend({
    tagName: 'li',
    template: 'facilityListItem',
    initialize: function() {
      _.bindAll(this, 'render');
      return this.model.on('change', this.render);
    },
    serialize: function() {
      return {
        fac: this.model.toJSON(),
        display_address: true
      };
    },
    cleanup: function() {
      return this.model.off(null, null, this);
    }
  });
  Facility.Views.List = Backbone.View.extend({
    template: 'facilityList',
    className: "facility-wrapper",
    events: {
      "click .refresh": "refreshLocation"
    },
    initialize: function() {
      _.bindAll(this, 'render', 'refreshLocation');
      this.collection.bind('reset', this.render);
    },
    serialize: function() {
      return {
        count: this.collection.length
      };
    },
    beforeRender: function() {
      var _this = this;
      return this.collection.each(function(facility) {
        return _this.insertView('.facility-list', new Facility.Views.ListItem({
          model: facility
        }));
      });
    },
    refreshLocation: function() {
      var _this = this;
      return app.fetchLocation().done(function(pos) {
        var dist;
        dist = .01;
        return _this.collection.fetch({
          data: {
            near: "" + pos.coords.latitude + "," + pos.coords.longitude + "," + dist
          }
        });
      });
    },
    cleanup: function() {
      return this.collection.off(null, null, this);
    }
  });
  Facility.Views.Detail = Backbone.View.extend({
    tagName: 'div',
    className: "facility-detail-wrapper well",
    template: 'facilityDetail',
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('reset', this.render);
      return this.model.bind('change', this.render);
    },
    serialize: function() {
      return {
        fac: this.model.toJSON()
      };
    }
  });
  return Facility;
});
