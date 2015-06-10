var fs = require('fs');
var exec = require("child_process").exec;
var express=require("express");
var multer  = require('multer');
var crypto = require('crypto');
var Promise = require('promise');
var convertor = require('./convert.js').convertor;
var utils = require('./utils.js')
var path = require('path');
var app=express();

var processPsdPool = {};
var responseTypeMap = {
    "html": "text/html",
    "legend": "application/json",
    "default": 'text/plain'
}
var getFileMd5 = function (path, callback) {
    var s = fs.readFileSync(path);
    var shasum = crypto.createHash('md5');
    shasum.update(s);
    callback(shasum.digest('hex'))
}

var getBufferMd5 = function (buffer, callback) {
    var shasum = crypto.createHash('md5');
    shasum.update(buffer);
    return callback(shasum.digest('hex'))
}

var ParsePsdProcess = function (file, req, res) {
    var me = this;
    var convertType = req.body.type || 'html';
    getBufferMd5(file.buffer, function (md5) {
        if(processPsdPool[md5]){
            return false;
        }
        fs.writeFile('..\/files\/'+md5+'.psd', file.buffer, function (err) {
            if(err){
                return console.log(err)
            }
            console.log('..\/files\/'+md5+'.psd saved!');
            processPsdPool[md5] = 1;
            me.psdName = md5;
            me.res = res;
            me.req = req;
            me.convertType = convertType;
            me.done = false;
            me.startParse()
        })
    })
}
ParsePsdProcess.prototype = {
    startParse: function () {
        var me = this;
        convertor('..\/files\/'+me.psdName+'.psd', me.convertType, function() {
            console.log('parse finished.');
            me.finishParse()
            processPsdPool[me.md5] = undefined;
            this.done=true;
        });
        // var p2h = exec(this.cmd , function (err, stdout, stderr) {
        //     console.log(me.cmd, 'execute')
        // });
        // p2h.stdout.on('data', function (data) {
        //     console.log('stdout: ' + data);
        //     processPsdPool[me.md5] = undefined;
        // });

        // p2h.stderr.on('data', function (data) {
        //     console.log('stderr: ' + data);
        //     processPsdPool[me.md5] = undefined;
        // });

        // p2h.on('close', function (code) {
        //     console.log('child process exited with code ' + code);
        //     me.finishParse()
        //     processPsdPool[me.md5] = undefined;
        //     this.done=true;
        // });
    },
    finishParse: function () {
        var me = this;
        var outputFile = '../files/'+this.psdName+'/output.txt';
        this.res.sendFile(path.resolve(outputFile), {}, function (err) {
            if (err) {
                if (err.code === "ECONNABORT" && res.statusCode == 304) {
                    // No problem, 304 means client cache hit, so no data sent.
                    console.log('304 cache hit for ' + outputFile);
                    return;
                }
                console.error("SendFile error:", err, " (status: " + err.status + ")");
                if (err.status) {
                    res.status(err.status).end();
                }
            } else {
                console.log('Sent:', outputFile);
            }
        });
        setTimeout(function () {
            // exec('rm -rf ..\/files\/'+me.psdName+'.psd ..\/files\/'+me.psdName+'/img');
        }, 10000);
    }
}


app.use(multer({ 
    dest: '../files/',
    inMemory: true,
    onFileUploadStart: function (file) {
        console.log(file.originalname + ' is starting ...')
    },
    onFileUploadComplete: function (file, req, res) {
        new ParsePsdProcess(file, req, res)
    }
}));

/*Handling routes.*/

app.get('/',function(req,res){
res.sendfile("index.html");
});


app.get('/querystate',function(req,res){
    res.writeHead(200, {'content-type':'application/json'});
    if(!req.query || !req.query.id){
        res.send('invalid id');
    }
    var result = utils.getParseState(req.query.id);
    console.log(result)
    res.end(result);
});


app.get('/static/*',function(req,res){
var filename = req.url.match(/\/static\/([^w]+)/i)[1];
res.sendfile(filename);
});


app.post('/upload/',function(req,res){});

/*Run the server.*/
app.listen(8099,function(){
console.log("Working on port 8099");
});
