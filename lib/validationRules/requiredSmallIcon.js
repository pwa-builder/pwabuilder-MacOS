'use strict';

var manifoldjsLib = require('pwabuilder-lib');

var validationConstants = manifoldjsLib.constants.validation,
    imageValidation =  manifoldjsLib.manifestTools.imageValidation;

var constants = require('../constants');

module.exports = function (manifestContent, callback) {
  var description = 'A 50x50 small icon is required for the installation of this sample app',
  platform = constants.platform.id,
  level = validationConstants.levels.warning,
  requiredIconSizes = ['50x50'];

  imageValidation(manifestContent, description, platform, level, requiredIconSizes, callback);
};
