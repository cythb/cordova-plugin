
var exec = require('cordova/exec');

var PLUGIN_NAME = 'QRCodeScannerPlugin';

var QRCodeScannerPlugin = {
  echo: function(phrase, cb) {
    exec(cb, null, PLUGIN_NAME, 'echo', [phrase]);
  },
  getDate: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'getDate', []);
  },
  show: function(success, error, options) {
    exec(success, error, PLUGIN_NAME, 'show', [options || {}]);
  },
  dismiss: function(success, error) {
    exec(success, error, PLUGIN_NAME, 'dismiss', []);
  }
};

module.exports = QRCodeScannerPlugin;
