var apn = require('apn');

var options = {
  token: {
    key: "modules/APNService/key/AuthKey_2226L755W8.p8",
    keyId: "2226L755W8",
    teamId: "GP3XQ4MR89"
  },
  production: false
};

var apnProvider = new apn.Provider(options);

exports.broadcast = function (message, deviceTokens, callback) {
    for (var index in deviceTokens) {
      let deviceToken = deviceTokens[index]["deviceToken"];
      sendNotification(message, {'messageFrom': 'Broadcast'}, deviceToken);
    }
}


exports.newMinedTransaction = function (deviceTokens, address, contractAddress, currency, amount, incoming, txid, fees) {
  var payload = {'address':address, 'peer': contractAddress, 'incoming': incoming, 'currency':currency, 'mined':true, 'value':amount, 'txid': txid, 'fees':fees};
  var message = "You sent "+amount+currency+" to "+contractAddress;
  if (incoming == true) {
    message = "You received "+amount+currency+" from "+contractAddress;
  }
  for (var index in deviceTokens) {
    let deviceToken = deviceTokens[index]["deviceToken"];
    sendNotification(message, payload, deviceToken);
  }
}

exports.newTransaction = function(deviceTokens, address, contractAddress, currency, amount, incoming, txid, fees) {
  var payload = {'address':address, 'peer': contractAddress, 'incoming': incoming, 'currency':currency, 'mined':false, 'value':amount, 'txid':txid, 'fees': fees};
  var message = "Sending "+amount+currency+" to "+contractAddress;
  if (incoming == true) {
    message = "Receiving "+amount+currency+" from "+contractAddress;
  }
  for (var index in deviceTokens) {
    let deviceToken = deviceTokens[index]["deviceToken"];
    sendNotification(message, payload, deviceToken);
  }
}

function sendNotification(message, payload, deviceToken) {
  var note = new apn.Notification();
  note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
  note.sound = "ping.aiff";
  note.body = message;
  note.title = "Transaction"
  note.payload = payload;
  note.topic = "com.danielriege.wallettracker";
  note.mutableContent = 1

  apnProvider.send(note, deviceToken).then( (result) => {
  //  callback(result);
  });
}
