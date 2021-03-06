var url = require('url');

// surrounds the pbx proj name with quotations to allow for names with spaces
function pbxProjNameHelper(str) {
    return '"' + str + '"';
}

/*
    - manifest: actual contents of the modified manifest
    - size:  string size of the image (assumes square atm) example: 16
    - sourceDir: root of the output
 */
function getSourcePathForIcon(manifest, size) {
    var squareValue = size + "x" + size;

    if (manifest.icons[squareValue] || manifest.icons[squareValue.toUpperCase()]) {
        var urlOrPath = manifest.icons[squareValue] || manifest.icons[squareValue.toUpperCase()];
        return url.parse(urlOrPath).pathname;
    } else if (manifest.icons[size]) {
        return manifest.icons[size];
    }

    // path to stock asset
    return size + "x" + size + ".png"
}

module.exports = {
    pbxProjNameHelper,
    getSourcePathForIcon,
};