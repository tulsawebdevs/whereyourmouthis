
define(["app", "backbone", "plugins/backbone.subset"], function(app, Backbone) {
  var Facility;
  Facility = app.module();
  Facility.Model = Backbone.Model.extend({
    defaults: {
      address: 'nowhere',
      city: 'someplace',
      state: 'Not OK',
      distance: null,
      name: '',
      type: '',
      latest_score: 50,
      display_address: '',
      "address": '',
      zip_code: ''
    },
    url: function() {
      return "" + app.api.startPoint + "facility/" + this.id + "/?format=json";
    },
    parse: function(res) {
      return res;
    },
    getDistance: function(pos) {
      var R, a, c, dLat, dist, dlng, lat1, lat2, lng1, lng2;
      R = 3961;
      lat1 = parseInt(this.get('lat'));
      lng1 = parseInt(this.get('lng'));
      lat2 = pos.coords.latitude;
      lng2 = pos.coords.longitude;
      dLat = (lat2 - lat1) * Math.PI / 180;
      dlng = (lng2 - lng1) * Math.PI / 180;
      lat1 = lat1 * Math.PI / 180;
      lat2 = lat2 * Math.PI / 180;
      a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dlng / 2) * Math.sin(dlng / 2) * Math.cos(lat1) * Math.cos(lat2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      dist = R * c;
      this.set('distance', Math.floor(dist), {
        silent: true
      });
      return dist;
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
  Facility.LocalCollection = Backbone.Subset.extend({
    sieve: function(facility) {
      var dist;
      dist = facility.getDistance(app.curPos);
      return dist <= app.localDist;
    }
  });
  Facility.Views.ListItem = Backbone.View.extend({
    tagName: 'li',
    template: 'facilityListItem',
    initialize: function() {
      _.bindAll(this, 'render', 'remove');
      this.model.on('change', this.render);
      return this.model.on('destroy', this.remove);
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
      this.collection.bind('change', this.render);
    },
    serialize: function() {
      return {
        count: this.collection.length
      };
    },
    beforeRender: function() {
      var _this = this;
      if (this.collection) {
        return this.collection.each(function(facility) {
          return _this.insertView('.facility-list', new Facility.Views.ListItem({
            model: facility
          }));
        });
      }
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
