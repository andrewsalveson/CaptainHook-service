var util    = require('util');
var spawn   = require('child_process').spawn;
var express = require('express');
var app     = express();
var morgan  = require('morgan');
var busboy  = require('connect-busboy');
var fs      = require('fs');
var port    = 8080;

fs.mkdirSync('/var/www/tmp');

app.use(morgan('dev')); // log every request to the console

app.use(busboy());

app.post('/file/gh',function(req,res){
  return res.json({message:"grasshopper file submitted"+arg});
});
app.post('/file/dyn',function(req,res){
  return res.json({message:"dynamo file submitted"})
});
app.post('/file/osm',function(req,res){
  console.log('osm received');
  req.pipe(req.busboy);
  var complete = 0;
  var oldStream, newStream;
  var tmpName =
    String((new Date()).getTime())+
    String(Math.random()).substr(10);
  var tmpPath = '/var/www/tmp/'+tmpName;
  var oldPath = tmpPath+'old';
  var newPath = tmpPath+'new';
  console.log('old',oldPath,'new',newPath);
  var onComplete = function(){
    console.log('check if complete == 2; complete:',complete);
    if(complete==2){
      console.log('all files uploaded, running Ruby command:');
      console.log('oldPath',oldPath);
      console.log('newPath',newPath);
      var diff = spawn('ruby',['']);
      // var diff = spawn('ruby',['/var/www/rb/osm_diff.rb',oldPath,newPath]);
      diff.stdout.on('data',function(sdata){
        res.write(sdata);
      });
      diff.stderr.on('data',function(edata){
        console.log('error:',edata);
        res.write(edata);
      });
      diff.on('exit',function(code){
        res.end();
        // fs.unlink(oldPath);
        // fs.unlink(newPath);
      });
    }
  };
  req.busboy.on('file',function(fieldname,file,filename){
    if(fieldname=="model"){
      console.log('creating stream for model');
      oldStream = fs.createWriteStream(oldPath);
      file.pipe(oldStream);
      oldStream.on('close',function(){
        console.log('model uploaded');
        complete++;
        onComplete();
      });
    }
    if(fieldname=="compare"){
      console.log('creating stream for compare');
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