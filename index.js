var express = require('express');
var app     = express();
var morgan  = require('morgan');
var port    = 8080;

app.use(morgan('dev')); // log every request to the console

app.get('/route/:arg',function(req,res){
  var arg = req.params.arg;
  return res.json({message:"ok "+arg});
});
app.listen(port);
console.log('magic is happening on port ' + port);