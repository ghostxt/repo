var fs = require('fs');
var request = require('request');
var Promise = require('promise');
var path = require('path');
var UploadImg = function (images, success) {
    console.log('start upload images')
    var count = 0;
    for(var i in images) {
        count++
    }
    var promise = new Promise(function (resolve, reject) {
        for(var i in images) {
            (function (name, src) {
                path.resolve(src)
                var r = request.post('http://wenku.baidu.com/pay/interface/newimageupload', function optionalCallback(err, httpResponse, body) { 
                    if(err){
                        console.log('upload image error: ', err, body);
                        return;
                    }
                    body = JSON.parse(body)
                    images[name] = body.data.image_url;
                    count --
                    if (count === 0 ){
                        console.log('upload finish')
                        resolve(images)
                    }
                })
                var form = r.form();
                var img =fs.createReadStream(src);
                form.append('coverImage', img, {filename: name});
                img.on('close', function(err) {
                    if(err){
                        console.error('read image failed:' + err);
                        return;
                    }
                    
                })
            })(i, images[i])
        }
    });
    promise.then(success)
    return promise;
}

exports.uploadImg = UploadImg

