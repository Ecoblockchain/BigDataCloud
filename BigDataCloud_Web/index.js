var os = require("os");

var fs = require('fs');
var app = require('express')();
var http = require('http').Server(app);
var WebSocketServer = require('ws').Server;
var socketServer = new WebSocketServer({server: http});

var serialport = require('serialport');
var Port = serialport.SerialPort;

//var myPortName = '/dev/cu.usbmodemfd121'; // for my laptop (different for everyone)

// var myPort = new Port(myPortName,{
// 	'baudrate':19200 // the Arduino's baud rate
// 	// 'parser': serialport.parsers.readline('\r\n') // arduino ends messages with .println()

// });

// myPort.on("open", function(){
// myPort.write('open');
// });

app.get('/', function(req,res){
	res.sendFile(__dirname+'/index.html');
});

app.get('/results.json', function(req,res){
	res.sendFile(__dirname+'/results.json');
});

app.get('/address', function(req, res){
	res.send(os.hostname());
});

socketServer.on('connection', function(socket){
	// console.log('client connected');
	socket.on('message', function(msg){
	// if(myPort){
	// 	myPort.write(msg);
	// 	myPort.write('\r\n');
	// 	myPort.write('\r\n');
	// }
		// console.log(msg);

		// steps to update json
		// 1. read the json file
		// 2. add to it
		// 3. write a new one replacing it

		fs.readFile('results.json', 'utf8', function (err, data) {
		  if (err) throw err;
		  obj = JSON.parse(data);
		  if(msg != ""){
		  obj.results.push(msg); // push in the new message

			fs.writeFile('results.json', JSON.stringify(obj, null, 4), function(err) {
			    if(err) {
			      console.log(err);
			    } else {
			      console.log("JSON saved!");
			    }
			}); 
		}

		});

		socket.send(msg);
	});
});

http.listen(3000, function(){
	console.log('listening on *:3000');
// 	var myAddress = http.address.address;
// console.log(myAddress);
});



