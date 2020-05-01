function pbxProjNameHelper(str) {
    if (str.indexOf(' ') !== -1) {
        return '"' + str + '"';
    }

    return str;
}

module.exports = {
    pbxProjNameHelper: pbxProjNameHelper
};