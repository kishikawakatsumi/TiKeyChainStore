# TiKeyChainStore

KeyChain module for Appcelerator Titanium mobile for iPhone


INSTALL YOUR MODULE
--------------------

1. Run `build.py` which creates your distribution
2. cd to `/Library/Application Support/Titanium`
3. copy this zip file into the folder of your Titanium SDK

REGISTER YOUR MODULE
---------------------

Register your module with your application by editing `tiapp.xml` and adding your module.
Example:

<modules>
	<module version="1.0.0">com.kishikawakatsumi.tikeychainstore</module>
</modules>

When you run your project, the compiler will know automatically compile in your module
dependencies and copy appropriate image assets into the application.

USING YOUR MODULE IN CODE
-------------------------

To use your module in code, you will need to require it. 

For example,
	var tikeychainstore = require('com.kishikawakatsumi.tikeychainstore');
	
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

## License
MIT License
