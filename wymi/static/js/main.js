(function() {
  var App, data;

  data = [
    {
      "address": "6119 E 11TH ST E TULSA, OK 74112",
      "city": "Tulsa",
      "id": "207",
      "latest_score": 100,
      "latitude": "36.14790800",
      "longitude": "-95.90880800",
      "name": "11TH STREET PUB",
      "resource_uri": "/api/v1/facility/208/",
      "state": "OK",
      "type": "Bar",
      "zip_code": "747"
    }, {
      "address": "6119 E 11TH ST E TULSA, OK 74112",
      "city": "Tulsa",
      "id": "208",
      "latest_score": 70,
      "latitude": "36.14790800",
      "longitude": "-95.90880800",
      "name": "11TH STREET PUB",
      "resource_uri": "/api/v1/facility/208/",
      "state": "OK",
      "type": "Bar",
      "zip_code": "456"
    }, {
      "address": "6119 E 11TH ST E TULSA, OK 74112",
      "city": "Tulsa",
      "id": "209",
      "latest_score": 20,
      "latitude": "36.14790800",
      "longitude": "-95.90880800",
      "name": "11TH STREET PUB",
      "resource_uri": "/api/v1/facility/208/",
      "state": "OK",
      "type": "Bar",
      "zip_code": "583"
    }
  ];

  window.wymi = {
    views: {},
    collections: {},
    models: {}
  };

  wymi.models.facility = Backbone.Model.extend({
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
      return "/api/v1/facility/" + this.id;
    },
    parse: function(res) {
      return res.objects[0];
    }
  });

  wymi.views.facilityDetail = Backbone.View.extend({
    tagName: 'div',
    template: _.template($('#facilityDetail').html()),
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    }
  });

  wymi.collections.facilities = Backbone.Collection.extend({
    model: wymi.models.facility,
    url: function() {
      return "/api/v1/facility/";
    },
    parse: function(res) {
      return res.objects;
    }
  });

  wymi.views.facilityListItem = Backbone.View.extend({
    tagName: 'li',
    template: _.template($('#facilityListItem').html()),
    events: {
      "click": "viewDetail"
    },
    initialize: function() {
      _.bindAll(this, 'render', 'remove');
      this.model.bind('change', this.render);
      return this.model.bind('destroy', this.remove);
    },
    viewDetail: function() {
      console.log("viewing detail " + this.model.id);
      return $('#detail').append(view.render().el);
    },
    render: function() {
      $(this.el).html(this.template({
        fac: this.model.toJSON(),
        display_address: this.display
      }));
      return this;
    }
  });

  App = Backbone.View.extend({
    el: $("#appview"),
    events: {
      "click #refreshLoc": "refreshLocation"
    },
    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll', 'render', 'refreshLocation');
      this.Facilities = new wymi.collections.facilities;
      this.Facilities.bind('add', this.addOne);
      this.Facilities.bind('reset', this.addAll);
      this.Facilities.bind('all', this.render);
      this.Facilities.reset(data);
      this.refreshLocation();
      this.initialLoadMap();
    },
    addOne: function(facility) {
      var view;
      console.log("adding " + (facility.get('name')));
      view = new wymi.views.facilityListItem({
        model: facility
      });
      return this.$('#facility-list').append(view.render().el);
    },
    addAll: function() {
      this.$('#facility-list').empty();
      return this.Facilities.each(this.addOne);
    },
    refreshLocation: function() {
      var _this = this;
      if (navigator.geolocation) {
        return navigator.geolocation.getCurrentPosition(function(pos) {
          return _this.Facilities.fetch({
            data: {
              lat: pos.coords.latitude,
              lon: pos.coords.longitude
            }
          });
        });
      }
    },
    initialLoadMap: function() {
      var loc;
      window.map = MQA.TileMap($("#map"), 18, loc = {
        lat: 39.743943,
        lng: -105.020089
      }, 'map');
    }
  });

  console.log('starting app');

  wymi.app = new App();

}).call(this);
