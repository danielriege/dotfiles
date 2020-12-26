// SETUP
var express = require("express");
var DeviceManegment = require('./modules/deviceManegment')
var APNService = require('./modules/APNService/APNService');

var btcSocket = require('socket.io-client')('http://localhost:32785');
var btcEventHandler = require('./modules/bitcoinEventHandler');

var app = express();
var bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
// END SETUP

// Websocket Listener
// Bitcoin
btcSocket.on('connect', () => {
  console.log('Connected to socket');
  btcSocket.emit('subscribe', 'inv');
});

btcSocket.on('tx', sanitizedTx => {
  // Unconfirmed Transactions
  console.log("BTC utx: " + sanitizedTx.txid);
  DeviceManegment.getAllAddresses("BTC", function(response) {
    if (response["status"] == "ok") {
      let addresses = response["result"];

      btcEventHandler.newUnminedTransaction(sanitizedTx.txid, addresses, function(response) {
        if (response["status"] == "ok") {
          let transaction = JSON.parse(response["result"]);
          DeviceManegment.getDeviceForAddress(transaction.address, "BTC", function(response) {
            if (response["status"] == "ok") {
              let deviceTokens = response["result"];
              APNService.newTransaction(deviceTokens, transaction.address, "unkown", "BTC", transaction.value, transaction.incoming);
            }
            return
          });
        }
      });
    }
    return;
  });
});

btcSocket.on('block', blockHash => {
  // For Confirmed Transactions
  console.log("BTC Block:"+blockHash);
  DeviceManegment.getAllAddresses("BTC", function(response) {
    if (response["status"] == "ok") {
      let addresses = response["result"];

      btcEventHandler.btcNewBlock(blockHash, addresses, function(response) {
        if (response["status"] == "ok") {
          let transaction = response["result"];
          DeviceManegment.getDeviceForAddress(transaction["address"], "BTC", function(response) {
            if (response["status"] == "ok") {
              let deviceTokens = response["result"];
              APNService.newMinedTransaction(deviceTokens, transaction["address"], "unkown", "BTC", transaction["value"], transaction["incoming"]);
            }
            return
          });
        }
      });
    }
    return;
  });
});

// END Websocket Listener

// API Routes
app.post("/register", function(req, res) {
  var deviceToken = req.body.deviceToken;
  var appVersion = req.body.appVersion;
  DeviceManegment.register(deviceToken, appVersion, function(response) {
    res.send(response);
  });
});

app.post("/addWallet", function(req, res) {
  var deviceToken = req.body.deviceToken;
  var address = req.body.address;
  var currency = req.body.currency;
  DeviceManegment.addWalletListener(deviceToken, address, currency, function(response) {
    res.send(response);
  });
});

app.post("/deleteWallet", function(req, res) {
  var deviceToken = req.body.deviceToken;
  var address = req.body.address;
  var currency = req.body.currency;
  DeviceManegment.deleteWalletListener(deviceToken, address, currency, function(response) {
    res.send(response);
  });
});

app.post("/broadcast", function(req, res) {
  var message = req.body.message;
  deviceManegment.getAllDeviceTokens(function(response) {
    if (response["status"] == "ok") {
      let deviceTokens = response["result"];
      APNService.broadcast(message, deviceTokens, function(response) {
        res.send(response);
      });
    }
  });
});

app.post("/testBlock", function(req, res) {
  var blockHash = req.body.block;
  btcGetTxFromBlock(blockHash);
});

app.listen(3000, function() {
  console.log("Started on PORT 3000");
});
// END API Routes
