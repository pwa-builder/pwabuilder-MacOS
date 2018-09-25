'use strict';

var should = require('should');

var lib = require('pwabuilder-lib');

var manifest = require('../../lib/manifest.js');

describe('manifest: sample platform Manifest', function () {
  describe('convertFromBase()', function () {
    it('Should return an Error if manifest info is undefined', function(done) {
      manifest.convertFromBase(undefined, function(err) {
        should.exist(err);
        err.should.have.property('message', 'Manifest content is empty or not initialized.');
        done();
      });
    });

    it('Should return an Error if content property is undefined', function(done) {
      var originalManifest = { key: 'value' };

      manifest.convertFromBase(originalManifest, function(err) {
        should.exist(err);
        err.should.have.property('message', 'Manifest content is empty or not initialized.');
        done();
      });
    });

    it('Should return an Error if start_url is missing', function (done) {
      var originalManifestInfo = {
        content: {}
      };

      manifest.convertFromBase(originalManifestInfo, function(err) {
        should.exist(err);
        err.should.have.property('message', 'Start URL is required.');
        done();
      });
    });

    it('Should return the transformed object', function (done) {
      var name = 'name';
      var siteUrl = 'start_url';

      var originalManifestInfo = {
        content: {
          'start_url': siteUrl,
          'name': name,
          'orientation' : 'landscape',
          'display': 'fullscreen'
        }
      };

      manifest.convertFromBase(originalManifestInfo, function(err, result) {
        should.not.exist(err);
        should.exist(result);
        /*jshint -W030 */
        result.should.have.property('content').which.is.an.Object;
        result.should.have.property('format', lib.constants.STRAWMAN_MANIFEST_FORMAT);

        var manifest = result.content;

        manifest.should.have.property('manifest_version');
        manifest.should.have.property('name', name);


        //manifest.app.should.have.property('urls').which.is.an.Array;
        //manifest.app.urls.should.containEql(siteUrl);


        done();
      });
    });

    it('Should return the transformed object with icons', function (done) {
      var name = 'name';
      var siteUrl = 'start_url';

      var originalManifestInfo = {
        content: {
          'start_url': siteUrl,
          'name': name,
          'orientation' : 'landscape',
          'display': 'fullscreen',
          'icons': [
          {
            'src': 'icon/lowres',
            'sizes': '64x64',
            'type': 'image/webp'
          },
          {
            'src': 'icon/hd_small',
            'sizes': '64x64'
          },
          {
            'src': 'icon/hd_hi',
            'sizes': '128x128',
            'density': '2'
          }]
        }
      };

      manifest.convertFromBase(originalManifestInfo, function(err, result) {
        should.not.exist(err);
        should.exist(result);
        /*jshint -W030 */
        result.should.have.property('content').which.is.an.Object;
        result.should.have.property('format', lib.constants.STRAWMAN_MANIFEST_FORMAT);

        var manifest = result.content;
        manifest.should.have.property('name', name);
        manifest.should.not.have.properties('orientation', 'display');


        //manifest.app.should.have.property('urls').which.is.an.Array;
        //manifest.app.urls.should.containEql(siteUrl);

        manifest.should.have.property('icons').which.is.an.Object;
        manifest.icons.should.containEql({'64': 'icon/hd_small'});
        manifest.icons.should.containEql({'128': 'icon/hd_hi'});

        done();
      });
    });
  });
});