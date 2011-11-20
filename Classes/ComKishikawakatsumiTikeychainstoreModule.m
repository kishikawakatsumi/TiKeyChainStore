/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComKishikawakatsumiTikeychainstoreModule.h"
#import "KeyChainStoreProxy.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComKishikawakatsumiTikeychainstoreModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID {
    return @"bf29e92f-478d-43dd-b25d-bcaed5c8009e";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId {
    return @"com.kishikawakatsumi.tikeychainstore";
}

#pragma mark Lifecycle

- (void)startup {
    // this method is called when the module is first loaded
    // you *must* call the superclass
    [super startup];
    
    NSLog(@"[INFO] %@ loaded",self);
}

- (void)shutdown:(id)sender {
    // this method is called when the module is being unloaded
    // typically this is during shutdown. make sure you don't do too
    // much processing here or the app will be quit forceably
    
    // you *must* call the superclass
    [super shutdown:sender];
}

#pragma mark Cleanup 

- (void)dealloc {
    // release any resources that have been retained by the module
    [super dealloc];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification*)notification {
    // optionally release any resources that can be dynamically
    // reloaded once memory is available - such as caches
    [super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

- (id)createKeychainStore:(id)args {
    NSArray *arr = (NSArray *)args;
    if (!arr || [arr count] == 0) {
        return [KeyChainStoreProxy keyChainStore];
    }
    
    NSDictionary *hash = [arr objectAtIndex:0];
    NSString *service = [TiUtils stringValue:[hash objectForKey:@"service"]];
    NSString *accessGroup = [TiUtils stringValue:[hash objectForKey:@"accessGroup"]];
    NSString *group = nil;
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        group = accessGroup;
    }
#endif
    
    KeyChainStoreProxy *store = [KeyChainStoreProxy keyChainStoreWithService:service accessGroup:group];
    return store;
}

@end
