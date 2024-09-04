var osc = require("osc"),
WebSocket = require("ws");

// Create an Express server app
// and serve up a directory of static files.
var express = require("express"),
    app = express()
   
const server = app.listen(8081);

app.use("/", express.static("./"));

var udpPort = new osc.UDPPort({
  localAddress: "0.0.0.0",
  localPort: 8082,
  metadata: true
});

udpPort.open()


// Listen for Web Socket requests.
var wss = new WebSocket.Server({
  server
});

// Listen for Web Socket connections.
wss.on("connection", function (socket) {
  var socketPort = new osc.WebSocketPort({
    socket: socket,
    metadata: true
  });

  socketPort.on("message", function (oscMsg) {
    console.log( "An OSC.js WebSocket Message was received!", oscMsg);
    udpPort.send( oscMsg, "127.0.0.1", 9000);
  });
});
