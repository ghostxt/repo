var fs = require('fs');
var path = require('path');


var utils = {
    getFolderPath: function(id) {
        var arr = __dirname.split('/');
        arr.pop();
        arr.push('files');
        arr.push(id);
        return arr.join('/');
    },
    setParseState: function(id, state) {
        var folderPath = utils.getFolderPath(id);
        var stateFilePath = folderPath+'/state.txt';
        fs.writeFileSync(stateFilePath, '{"state": '+state+'}')

    },
    getParseState: function(id) {
        var folderPath = utils.getFolderPath(id);
        var stateFilePath = folderPath+'/state.txt';
        console.log(stateFilePath)
        var state = fs.readFileSync(stateFilePath, 'utf-8');
        return state;
    }
}
module.exports = utils