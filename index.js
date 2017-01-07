var util    = require('util');
var spawn   = require('child_process').spawn;
var express = require('express');
var app     = express();
var morgan  = require('morgan');
var busboy  = require('connect-busboy');
var fs      = require('fs');
var port    = 8080;

app.use(morgan('dev')); // log every request to the console

app.use(busboy());

app.post('/file/gh',function(req,res){
  return res.json({message:"grasshopper file submitted"+arg});
});
app.post('/file/dyn',function(req,res){
  return res.json({message:"dynamo file submitted"})
});
app.post('/file/osm',function(req,res){
  req.pipe(req.busboy);
  var complete = 0;
  var oldStream, newStream;
  var tmpName = String(Math.random()).substr(10)+String((new Date()).getTime());
  var tmpPath = __dirname + '/tmp/'+tmpName;
  var oldPath = tmpPath+'old';
  var newPath = tmpPath+'new';
  var onComplete = function(){
    if(complete==2){
      console.log('all files uploaded');
      var diff = spawn('ruby',['./rb/osm_diff.rb',oldPath,newPath]);
      diff.stdout.on('data',function(data){
        res.write(data);
      });
      diff.stderr.on('data',function(data){
        console.log('error:',data);
        res.write(data);
      });
      diff.on('exit',function(code){
        res.end();
        fs.unlink(oldPath);
        fs.unlink(newPath);
      });
    }
  };
  req.busboy.on('file',function(fieldname,file,filename){
    if(fieldname=="model"){
      oldStream = fs.createWriteStream(oldPath);
      file.pipe(oldStream);
      oldStream.on('close',function(){
        console.log('model uploaded');
        complete++;
        onComplete();
      });
    }
    if(fieldname=="compare"){
      newStream = fs.createWriteStream(newPath);
      file.pipe(newStream);
      newStream.on('close',function(){
        console.log('compare uploaded');
        complete++;
        onComplete();
      });
    }
  });
});
app.post('/viz',function(req,res){
  return res.send("what am I doing?");
});
app.listen(port);
console.log('magic is happening on port ' + port);