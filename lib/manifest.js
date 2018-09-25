'use strict';

var url = require('url'),
    Q = require('q');
var lib = require('pwabuilder-lib');
var utils = lib.utils;


// here is your base funcion, called by platform.js
//the idea here is to handle any transformations from the W3C manifest to your platform Manifest
function convertFromBase(manifestInfo, callback) {

//check to make sure you have a manifest before you try to transform it
  if (!manifestInfo || !manifestInfo.content) {
    return Q.reject(new Error('Manifest content is empty or not initialized.')).nodeify(callback);
  }
 
 //good to have a local ref to work with.  You'll see that you work work off of manifestInfo.content in platform.js 
  var originalManifest = manifestInfo.content;


//here we are going to convert the W3C manifest to our strawman app
//note that you might need to re-map some values, or add some new ones
//if your platform manifest is XML instead of JSON, you might want to read from a manifest template file, (or string
// depending on how big the XML is) and insert your W3C manifest values
  var manifest = {
    'manifest_version': 2,
    'name': originalManifest.name || 'PWABuilder Rockin App',
    'scope': originalManifest.scope || '/',
    'display': originalManifest.display || 'browser',
    'start_url': originalManifest.start_url, 
    'short_name': originalManifest.short_name,
    'theme_color': originalManifest.theme_color || 'red'
  };

  // Here's a pretty standard practice of mapping the icons from the W3C to the manifest object you pass back to platform.js
  //if you don't use images in your platform, delete this stuff
  if (originalManifest.icons && originalManifest.icons.length) {
    var icons = {};
    for (var i = 0; i < originalManifest.icons.length; i++) {
      var icon = originalManifest.icons[i];
      var size = ['16x16', '32x32', '64x64', '128x128', '256x256', '512x512', '1024x1024'].indexOf(icon.sizes); //specify which size icons from manifest to keep
    if(size >=0){
        icons[icon.sizes] = icon.src;
    }

    }
    manifest.icons = icons;
  }

  // NOTE: you may need to map permissions in this file as well, if you app supports permissions, pull them from
  //originalManifest.mjs_api_access
 

//This is important, this will be converted into a file that lives on your project root.  Manifoldjs uses it, and it's a good record
//to have around, so make sure you leave this.  Add extra info to it if you think it would be handy
  var convertedManifestInfo = {
    'content': manifest,
    'format': lib.constants.STRAWMAN_MANIFEST_FORMAT
  };
  //this is the return, that's all she wrote!
  return Q.resolve(convertedManifestInfo).nodeify(callback);
}

module.exports = {
  convertFromBase: convertFromBase
};
