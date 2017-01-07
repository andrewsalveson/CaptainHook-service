var express = require('express');
var app     = express();
var morgan  = require('morgan');
var port    = 8080;

app.use(morgan('dev')); // log every request to the console

// grasshopper handler
app.post('/file/gh',function(req,res){
  return res.json({message:"grasshopper file submitted"+arg});
});
app.post('/file/dyn',function(req,res){
  return res.json({message:"dynamo file submitted"})
})
app.post('/file/osm',function(req,res){
  return res.json({message:"openStudio measures file submitted"});
})
app.listen(port);
console.log('magic is happening on port ' + port);