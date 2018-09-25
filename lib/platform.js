////////////////////////////////
//*Platform.js
//*you might not need to make changes in this file.  If you follow the following conventions, no changes are nessecarry
//*   1. Your managing the manifest transformations inside of manifest.js.  Follow required steps
//*   2. Your Validating via the validation rules like this example
//*   3. You require images which sizes are defined in constants.js
//*   4. You are converting from JSON to JSON, if converting to XML or some other markup, see the comments and exmaple inline
//*      around line 93 you'll want to adjust the name of the file you are generating
//*   5. Your not moving any additional files into the platform folder, if so, see the comments and example inline
//*      see line 97 in the code for an example of how to do that.
//*     
///////////////////////////////
'use strict';

var path = require('path'),
    url = require('url'),
    util = require('util');
    
var Q = require('q');

var manifoldjsLib = require('pwabuilder-lib');

var PlatformBase = manifoldjsLib.PlatformBase,
    manifestTools = manifoldjsLib.manifestTools,
    CustomError = manifoldjsLib.CustomError,
    fileTools = manifoldjsLib.fileTools,
    iconTools = manifoldjsLib.iconTools;

var constants = require('./constants'),
    manifest = require('./manifest');
   
function Platform (packageName, platforms) {

  var self = this;

  PlatformBase.call(this, constants.platform.id, constants.platform.name, packageName, __dirname);

  // save platform list
  self.platforms = platforms;

  // override create function
  self.create = function (w3cManifestInfo, rootDir, options, callback) {

    self.info('Generating the ' + constants.platform.name + ' app...');
    
    //var platformDir = path.join(rootDir, constants.platform.id);
    var assetsDir = path.join(self.baseDir, 'assets');
    var platformDir = self.getOutputFolder(rootDir);
    var manifestDir = path.join(platformDir, 'PWAInfo');
    var imagesDir = path.join(manifestDir, 'images');
    var macOSpwaDir = path.join(platformDir, 'MacOSpwa');
    var xcodeProjDir = path.join(platformDir, 'MacOSpwa.xcodeproj');
    var testsDir = path.join(platformDir, 'MacOSpwaTests');
    var uiTestsDir = path.join(platformDir, 'MacOSpwaUITests');
    var xcodeAssetsDir = path.join(macOSpwaDir, 'Assets.xcassets');
    var appIconDir = path.join(xcodeAssetsDir, 'AppIcon.appiconset');

    var tempAppName = 'MacOSpwa';
    var newAppName = w3cManifestInfo.content.short_name;
    
    // convert the W3C manifest to a platform-specific manifest
    var platformManifestInfo;
    return manifest.convertFromBase(w3cManifestInfo)
      // if the platform dir doesn't exist, create it
      .then(function (manifestInfo) {
        platformManifestInfo = manifestInfo;         
        self.debug('Creating the ' + constants.platform.name + ' app folder...');
        return fileTools.mkdirp(platformDir);
      })
      // download icons to the app's folder
      .then(function () {
        return self.downloadIcons(platformManifestInfo.content, w3cManifestInfo.content.start_url, imagesDir);
      })
      // copy the documentation
      .then(function () {
        return self.copyDocumentation(platformDir);
      })      
      // write generation info (telemetry)
      .then(function () {
        return self.writeGenerationInfo(w3cManifestInfo, platformDir);
      })
      // persist the platform-specific manifest
      .then(function () {
        self.debug('Copying the ' + constants.platform.name + ' manifest to the app folder...');
        //this is assuming that your manifest is named manifest.json, if it's xml call it manifest.xml, or call it whatever you want
        var manifestFilePath = path.join(manifestDir, 'manifest.json');
        
        return manifestTools.writeToFile(platformManifestInfo, manifestFilePath);
      })

      // copy MacOSpwa folder
      .then(function () {
        var inputDir = path.join(assetsDir, 'MacOSpwa');
        self.info('Copying folder "' + inputDir + '" to target: ' + macOSpwaDir + '...');
        return fileTools.copyFolder(inputDir, macOSpwaDir)
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to copy the project assets to the source folder.', err));
          });
      })
      // copy MacOSpwa.xcodeproj folder
      .then(function () {
        var inputDir = path.join(assetsDir, 'MacOSpwa.xcodeproj');
        self.info('Copying folder "' + inputDir + '" to target: ' + xcodeProjDir + '...');
        return fileTools.copyFolder(inputDir, xcodeProjDir)
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to copy the project assets to the source folder.', err));
          });
      })
      // copy MacOSpwaTests folder
      .then(function () {
        var inputDir = path.join(assetsDir, 'MacOSpwaTests');
        self.info('Copying folder "' + inputDir + '" to target: ' + testsDir + '...');
        return fileTools.copyFolder(inputDir, testsDir)
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to copy the project assets to the source folder.', err));
          });
      })
      // copy MacOSpwaUITests folder
      .then(function () {
        var inputDir = path.join(assetsDir, 'MacOSpwaUITests');
        self.info('Copying folder "' + inputDir + '" to target: ' + uiTestsDir + '...');
        return fileTools.copyFolder(inputDir, uiTestsDir)
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to copy the project assets to the source folder.', err));
          });
      })

      /* RENAMING APP NAME */
      //Find and replace menu item title
      .then(function () {
        var baseString = 'menuItem title="'
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace menu key submenu title
      .then(function () {
        var baseString = 'key="submenu" title="'
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace about title
      .then(function () {
        var baseString = 'title="About '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace hide title
      .then(function () {
        var baseString = 'title="Hide '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace quit title
      .then(function () {
        var baseString = 'title="Quit '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace help title
      .then(function () {
        var baseString = 'menuItem title="'
        var findString = baseString + tempAppName + ' Help';
        var replaceString = baseString + newAppName + ' Help';
        var filePath = path.join(macOSpwaDir, 'Base.lproj/Main.storyboard');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })

      //Find and replace product name in pbxproj (2 instances)
      .then(function () {
        var baseString = 'name = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      .then(function () {
        var baseString = 'productName = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace product name in pbxproj for Tests
      .then(function () {
        var baseString = 'name = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace product name in pbxproj for UITests
      .then(function () {
        var baseString = 'name = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace PRODUCT_NAME in pbxproj (2 occurences)
      .then(function () {
        var baseString = 'PRODUCT_NAME = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      .then(function () {
        var baseString = 'PRODUCT_NAME = '
        var findString = baseString + tempAppName;
        var replaceString = baseString + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      //Find and replace TEST_HOST in pbxproj (2 occurences)
      .then(function () {
        var baseString = '(BUILT_PRODUCTS_DIR)/'
        var findString = baseString + tempAppName + '.app/Contents/MacOS/' + tempAppName;
        var replaceString = baseString + newAppName + '.app/Contents/MacOS/' + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })
      .then(function () {
        var baseString = '(BUILT_PRODUCTS_DIR)/'
        var findString = baseString + tempAppName + '.app/Contents/MacOS/' + tempAppName;
        var replaceString = baseString + newAppName + '.app/Contents/MacOS/' + newAppName;
        var filePath = path.join(xcodeProjDir, 'project.pbxproj');
        self.info('Replacing ' + findString + ' in "' + filePath + '" to ' + replaceString + '...');
            return fileTools.replaceFileContent(filePath,
                function (data) {
                  return (data).replace(findString, replaceString);
                }
            )
          .catch(function (err) {
            return Q.reject(new CustomError('Failed to find and replace in ' + filePath, err));
          });
      })

      
      // Copy images from newly created PWAInfo/images directory into Mac OS xassets folder
      .then(function () {
        var fileName1 = '16x16.png';
        var fileName2 = 'icon_16.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '32x32.png';
        var fileName2 = 'icon_32.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '64x64.png';
        var fileName2 = 'icon_64.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '128x128.png';
        var fileName2 = 'icon_128.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '256x256.png';
        var fileName2 = 'icon_256.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '512x512.png';
        var fileName2 = 'icon_512.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '1024x1024.png';
        var fileName2 = 'icon_1024.png'
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })

      //Create copies of icon sizes 32x32, 256x256 and 512x512 for xcassets folder
      .then(function () {
        var fileName1 = '32x32.png';
        var fileName2 = 'icon_32-1.png';
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '256x256.png';
        var fileName2 = 'icon_256-1.png';
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      .then(function () {
        var fileName1 = '512x512.png';
        var fileName2 = 'icon_512-1.png';
        var source = path.join(imagesDir, fileName1);
        var target = path.join(appIconDir, fileName2);

        self.info('Copying "' + source + '" to target: ' + target + '...');
        return fileTools.copyFile(source, target);
      })
      

      .nodeify(callback);
  };
}

util.inherits(Platform, PlatformBase);

module.exports = Platform;
