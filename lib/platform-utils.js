// surrounds the pbx proj name with quotations to allow for names with spaces
function pbxProjNameHelper(str) {
    return '"' + str + '"';
}

module.exports = {
    pbxProjNameHelper: pbxProjNameHelper
};