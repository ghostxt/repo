var fs = require('fs');
var utils = require('./utils.js');
var path = require('path');



module.exports.querystate = function(id) {
    var folderPath = utils.getFolderPath();
    var targetFile = folderPath + 'state.txt';
    return fs.readFileSync(path(targetFile), 'utf-8');
};