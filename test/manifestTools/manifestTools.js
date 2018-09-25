'use strict';

var should = require('should');

var lib = require('pwabuilder-lib');

var manifest = require('../../lib/manifest.js');

describe('Manifest Tools', function () {
  describe('getManifestFromFile()', function () {
    it('Should return an Error if custom format convert return an error', function(done) {
      var manifestInfo = { content: { 'name': 'test' }, format: 'W3C' };
      manifest.convertFromBase(manifestInfo, function(err) {
        should.exist(err);
        err.should.have.property('message', 'Start URL is required.');
        done();
      });
    });

    it('Convert from W3C to platform template', function (done) { 
      var manifestInfo = {
        content: {
          'name': 'Google Mail',
          'short_name': 'GMail',
          'start_url': 'http://mail.google.com/mail/',
          'icons': [{
            'src': 'icon_64.png',
            'sizes': '64x64'
          }, {
            'src': 'icon_128.png',
            'sizes': '128x128'
          }],
          'orientation' : 'landscape',
          'display': 'fullscreen'
        },
        format: 'w3c'
      };

      var expectedManifestInfo = {
        content: {
          'name': 'Google Mail',
          "start_url": "http://mail.google.com/mail/",
          'color': 'red',
          'icons': {
            '64': 'icon_64.png',
            '128': 'icon_128.png'
          },
          'manifest_version': 2
        },
        format: lib.constants.STRAWMAN_MANIFEST_FORMAT
      };

      manifest.convertFromBase(manifestInfo, function(err, result) {
        should.not.exist(err);
        result.should.be.eql(expectedManifestInfo);
        done();
      });
    });
  });
});