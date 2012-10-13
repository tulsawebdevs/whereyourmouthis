// Set the require.js configuration for your application.
require.config({

  // Initialize the application with the main application file.
  deps: ["main"],

  paths: {
    // JavaScript folders.
    libs: "../js/libs",
    plugins: "../js/plugins",
    vendor: "../vendor",

    // Libraries.
    jquery: "../js/libs/jquery",
    lodash: "../js/libs/lodash",
    backbone: "../js/libs/backbone",
    bootstrap: "../js/libs/bootstrap"
  },

  shim: {
    // Backbone library depends on lodash and jQuery.
    backbone: {
      deps: ["lodash", "jquery"],
      exports: "Backbone"
    },
    
    bootstrap: {
      deps: ["jquery"],
      exports: "$"
    },
    // Backbone.LayoutManager depends on Backbone.
    "plugins/backbone.layoutmanager": ["backbone"],
    // "plugins/backbone.paginator": ["backbone"],
    "plugins/backbone.subset": ["backbone"]
  }

});
