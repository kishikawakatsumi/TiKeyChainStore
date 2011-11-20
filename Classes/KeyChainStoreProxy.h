//
//  KeyChainStoreProxy.h
//  tikeychainstore
//
//  Created by Kishikawa Katsumi on 11/11/20.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"

@interface KeyChainStoreProxy : TiProxy {
    NSString *service;
    NSString *accessGroup;
    NSMutableDictionary *itemsToUpdate;
}

@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *accessGroup;

+ (KeyChainStoreProxy *)keyChainStore;
+ (KeyChainStoreProxy *)keyChainStoreWithService:(NSString *)service;
+ (KeyChainStoreProxy *)keyChainStoreWithService:(NSString *)service accessGroup:(NSString *)accessGroup;
- (id)init;
- (id)initWithService:(NSString *)service;
- (id)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

- (void)setKeyChainItem:(NSDictionary *)item;
- (void)setString:(NSString *)string forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;

- (void)removeItemForKey:(NSString *)key;
- (void)removeAllItems;

- (void)synchronize;

@end
