
define(["app", "backbone"], function(app, Backbone) {
  var Router;
  Router = Backbone.Router.extend({
    routes: {
      "": "index"
    },
    index: function() {
      return console.log('got here, really');
    }
  });
  return Router;
});
