var fs = require('fs');
var exec = require("child_process").exec;
var crypto = require('crypto');
var Promise = require('promise');
path = require('path');


var getFileMd5 = function (path, callback) {
    var s = fs.readFileSync(path);
    var shasum = crypto.createHash('sha1');
    shasum.update(s);
    callback(shasum.digest('hex'))
}
getFileMd5('../files/03-1429246558745.psd',function () {
    console.log(1)
})