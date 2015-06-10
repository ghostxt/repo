var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var uploadImg = require('./uploadImg.js').uploadImg;
var convertType;
var psdFilename;
var folderPath;
var imgPath;
var getFileName = function(src) {
    var filename = src.split('/').pop();
    return filename.substr(0, filename.lastIndexOf('.'));    
};

var replaceImageSrc = function (source, target) {
    if(convertType == 'legend'){
        source = JSON.parse(source);
        source.thumbnailUrl = target.thumbnailUrl;
        var components = source.components;
        for(var i in components){
            if(components[i].type == 'image'){
                var fileName = getFileName(components[i].attributes.src);
                if(fileName in target ){
                    components[i].attributes.src = target[fileName];
                }
            }
        }
        return JSON.stringify(source)
    }
    if(convertType == 'html'){
        for(var i in target){
            source = source.replace(imgPath + '/' + i + '.png', target[i]);
        }
        return source
    }
};
var getImages = function (str) {
    var data
    var result = {};
    if(convertType == 'legend'){
        data = JSON.parse(str);
        result.thumbnailUrl = data.thumbnailUrl;
        var components = data.components;
        for(var i in components){
            if(components[i].type == 'image'){
                var attr = components[i].attributes;
                if(!attr.src){
                    console.error('invalid image file');
                }
                var filename = getFileName(attr.src).replace('../files/'+psdFilename, folderPath);
                result[filename] = attr.src;
            }
        }
    }
    if(convertType == 'html'){
        var regexp = new RegExp('(\.\.\/files\/'+psdFilename+'\/img\/[^*(?=\"\))]+)','ig');
        data = str.match(regexp);
        for(var i = 0; i< data.length; i++){
            var filename = getFileName(data[i]);
            result[filename] = data[i];
        }
    }
    return result;
};

var getUploadCmd = function (data) {
    //上传转化的图片到hiphoto服务器
    var imgs = {};
    for(var i in data){
        imgs[i] = data[i].src;
    }
    return imgs;
};

module.exports.convertor = function(filename, type, callback) {
    convertType = type;
    psdFilename = getFileName(filename);
    folderPath = (function() {
        var arr = __dirname.split('/');
        arr.pop();
        arr.push('files')
        arr.push(psdFilename)
        return arr.join('/')
    })();
    imgPath = folderPath + '/img';
    var cmdInitPath = 'mkdir '+folderPath+';rm -rf ' + imgPath + ';mkdir ' + imgPath + ';touch ' + folderPath + '/' +'output.txt';
    var cmdGenerateThumbnail = 'ruby ../psdparser/bin/thumbnailGenerator ' + filename + ' ' + folderPath + '/output.txt';
    var cmdParsePsd = 'ruby ../psdparser/bin/psdparser ' + filename + ' ' + folderPath + '/output.txt ' + convertType;
    console.log(cmdParsePsd);
    var initPath = exec(cmdInitPath);
    initPath.stdout.on('end', function(chunk) {
        var generateThumbnail = exec(cmdGenerateThumbnail);
        generateThumbnail.stdout.on('end', function(chunk) {
            console.log('Processing: \n', cmdParsePsd)
            var parsePsd = exec(cmdParsePsd);
            parsePsd.stdout.on('end', function(chunk) {
                var str = fs.readFileSync(folderPath + '/output.txt', 'utf8');
                var result = getImages(str, convertType);
                uploadImg(result, function(stdout) {
                    var data = replaceImageSrc(str, stdout);
                    fs.writeFileSync(folderPath + '/output.txt', data);
                    console.log('replace image finished');
                    callback();
                });
            });
        });
    });

};