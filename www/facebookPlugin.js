var exec = require('cordova/exec');

var facebookPlugin = {};

facebookPlugin.logPurchase = function() {
  exec(null, null, 'FacebookPlugin', 'logPurchase', getNArgs(arguments, 4));
};

facebookPlugin.logEvent = function() {
  exec(null, null, 'FacebookPlugin', 'logEvent', getNArgs(arguments, 4));
};

function getNArgs(args, n) {
  var result = [];
  args = args || [];

  for (var i = 0; i < n; i++) {
    result[i] = args[i] === undefined ? null : args[i];
  }

  return result;
}

module.exports = facebookPlugin;