// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel({
  top: 20,
  height: 30,
  left: 10,
  right: 10,
  text: 'keychain test',
});
window.add(label);

window.open();

// TODO: write your module tests here
var tikeychainstore = require('com.kishikawakatsumi.tikeychainstore');
Ti.API.info("module is => " + tikeychainstore);

var store = tikeychainstore.createKeychainStore({
  service: 'com.kishikawakatsumi.ti'
});

store.setKeyChainItem ({
  key: 'userame',
  value: 'kishikawakatsumi@mac.com'
});

store.setKeyChainItem ({
  key: 'password',
  value: 'password1234'
});

store.synchronize;

Ti.API.info(store.description);
