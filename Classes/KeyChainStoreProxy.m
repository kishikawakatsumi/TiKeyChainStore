//
//  KeyChainStoreProxy.m
//  tikeychainstore
//
//  Created by Kishikawa Katsumi on 11/11/20.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import "KeyChainStoreProxy.h"

static NSString *defaultService;

@interface KeyChainStoreProxy()

+ (NSString *)stringForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (void)setString:(NSString *)value forKey:(NSString *)key;
+ (void)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service;
+ (void)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (NSData *)dataForKey:(NSString *)key;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (void)setData:(NSData *)data forKey:(NSString *)key;
+ (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service;
+ (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (void)removeItemForKey:(NSString *)key;
+ (void)removeItemForKey:(NSString *)key service:(NSString *)service;
+ (void)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (void)removeAllItems;
+ (void)removeAllItemsForService:(NSString *)service;
+ (void)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup;

@end

@implementation KeyChainStoreProxy

@synthesize service;
@synthesize accessGroup;

+ (void)initialize {
    defaultService = [[[NSBundle mainBundle] bundleIdentifier] retain];
}

+ (NSString *)stringForKey:(NSString *)key {
    return [KeyChainStoreProxy stringForKey:key service:defaultService accessGroup:nil];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service {
    return [KeyChainStoreProxy stringForKey:key service:service accessGroup:nil];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    NSData *data = [KeyChainStoreProxy dataForKey:key service:service accessGroup:accessGroup];
    if (data) {
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return nil;
}

+ (void)setString:(NSString *)value forKey:(NSString *)key {
    [KeyChainStoreProxy setString:value forKey:key service:defaultService accessGroup:nil];
}

+ (void)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service {
    [KeyChainStoreProxy setString:value forKey:key service:service accessGroup:nil];
}

+ (void)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data forKey:key service:service accessGroup:accessGroup];
}

+ (NSData *)dataForKey:(NSString *)key {
    return [KeyChainStoreProxy dataForKey:key service:defaultService accessGroup:nil];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service {
    return [KeyChainStoreProxy dataForKey:key service:service accessGroup:nil];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
	if (!key) {
        NSAssert(NO, @"key must not be nil.");
		return nil;
	}
	if (!service) {
        service = defaultService;
	}
    
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:kSecMatchLimitOne forKey:kSecMatchLimit];
	[query setObject:service forKey:kSecAttrService];
    [query setObject:key forKey:kSecAttrGeneric];
    [query setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
    
	NSData *data = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&data);
	if (status != errSecSuccess) {
		NSLog(@"%s|SecItemCopyMatching: error(%ld)", __func__, status);
	}
    
    return [data autorelease];
}

+ (void)setData:(NSData *)data forKey:(NSString *)key {
    [KeyChainStoreProxy setData:data forKey:key service:defaultService accessGroup:nil];
}

+ (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service {
    [KeyChainStoreProxy setData:data forKey:key service:service accessGroup:nil];
}

+ (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
	if (!key) {
        NSAssert(NO, @"key must not be nil.");
		return;
	}
	if (!service) {
        service = defaultService;
	}
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:service forKey:kSecAttrService];
    [query setObject:key forKey:kSecAttrGeneric];
    [query setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
    
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, NULL);
	if (status == errSecSuccess) {
        if (data) {
            NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
            [attributesToUpdate setObject:data forKey:kSecValueData];
            
            status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributesToUpdate);
            if (status != errSecSuccess) {
                NSLog(@"%s|SecItemUpdate: error(%ld)", __func__, status);
            }
        } else {
            [self removeItemForKey:key service:service accessGroup:accessGroup];
        }
	} else if (status == errSecItemNotFound) {
		NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
		[attributes setObject:kSecClassGenericPassword forKey:kSecClass];
        [attributes setObject:service forKey:kSecAttrService];
        [attributes setObject:key forKey:kSecAttrGeneric];
        [attributes setObject:key forKey:kSecAttrAccount];
		[attributes setObject:data forKey:kSecValueData];
		
		status = SecItemAdd((CFDictionaryRef)attributes, NULL);
		if (status != errSecSuccess) {
			NSLog(@"%s|SecItemAdd: error(%ld)", __func__, status);
		}		
	} else {
		NSLog(@"%s|SecItemCopyMatching: error(%ld)", __func__, status);
	}
}

+ (void)removeItemForKey:(NSString *)key {
    [KeyChainStoreProxy removeItemForKey:key service:defaultService accessGroup:nil];
}

+ (void)removeItemForKey:(NSString *)key service:(NSString *)service {
    [KeyChainStoreProxy removeItemForKey:key service:service accessGroup:nil];
}

+ (void)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
	if (!key) {
        NSAssert(NO, @"key must not be nil.");
		return;
	}
	if (!service) {
        service = defaultService;
	}
	
	NSMutableDictionary *itemToDelete = [NSMutableDictionary dictionary];
	[itemToDelete setObject:kSecClassGenericPassword forKey:kSecClass];
	[itemToDelete setObject:service forKey:kSecAttrService];
    [itemToDelete setObject:key forKey:kSecAttrGeneric];
    [itemToDelete setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [itemToDelete setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
	
	OSStatus status = SecItemDelete((CFDictionaryRef)itemToDelete);
	if (status != errSecSuccess && status != errSecItemNotFound) {
		NSLog(@"%s|SecItemDelete: error(%ld)", __func__, status);
	}
}

+ (NSArray *)itemsForService:(NSString *)service accessGroup:(NSString *)accessGroup {
	if (!service) {
        service = defaultService;
	}
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:(id)kCFBooleanTrue forKey:kSecReturnAttributes];
	[query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:kSecMatchLimitAll forKey:kSecMatchLimit];
	[query setObject:service forKey:kSecAttrService];
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
	
	CFArrayRef result = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
	if (status == errSecSuccess || status == errSecItemNotFound) {
		return [(NSArray *)result autorelease];
	} else {
		NSLog(@"%s|SecItemCopyMatching: error(%ld)", __func__, status);
		return nil;
	}
}

+ (void)removeAllItems {
    [self removeAllItemsForService:defaultService accessGroup:nil];
}

+ (void)removeAllItemsForService:(NSString *)service {
    [self removeAllItemsForService:service accessGroup:nil];
}

+ (void)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup {
    NSArray *items = [KeyChainStoreProxy itemsForService:service accessGroup:accessGroup];    
    for (NSDictionary *item in items) {
        NSMutableDictionary *itemToDelete = [NSMutableDictionary dictionaryWithDictionary:item];
        [itemToDelete setObject:kSecClassGenericPassword forKey:kSecClass];
        
        OSStatus status = SecItemDelete((CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess) {
            NSLog(@"%s|SecItemDelete: error(%ld)", __func__, status);
            NSLog(@"%@", itemToDelete);
        }
    }
}

#pragma mark -

+ (KeyChainStoreProxy *)keyChainStore {
    return [[[KeyChainStoreProxy alloc] initWithService:defaultService] autorelease];
}

+ (KeyChainStoreProxy *)keyChainStoreWithService:(NSString *)service {
    return [[[KeyChainStoreProxy alloc] initWithService:service] autorelease];
}

+ (KeyChainStoreProxy *)keyChainStoreWithService:(NSString *)service accessGroup:(NSString *)accessGroup {
    return [[[KeyChainStoreProxy alloc] initWithService:service accessGroup:accessGroup] autorelease];
}

- (id)init {
    return [self initWithService:defaultService accessGroup:nil];
}

- (id)initWithService:(NSString *)s {
    return [self initWithService:s accessGroup:nil];
}

- (id)initWithService:(NSString *)s accessGroup:(NSString *)group {
    self = [super init];
    if (self) {
        if (!s) {
            s = defaultService;
        }
        service = [s copy];
        accessGroup = [group copy];
        if (accessGroup) {
#if !TARGET_IPHONE_SIMULATOR
            [itemsToUpdate setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
        }
		
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:itemsToUpdate];
        [query setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        
        NSMutableDictionary *result = nil;
        OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecSuccess) {
            itemsToUpdate = [[NSMutableDictionary alloc] initWithDictionary:result];
		} else {
            itemsToUpdate = [[NSMutableDictionary alloc] init];
        }
        [result release];
    }
    return self;
}

- (void)dealloc {
    [service release];
    [accessGroup release];
    [itemsToUpdate release];
    [super dealloc];
}

#pragma mark -

- (NSString *)description {
    NSArray *items = [KeyChainStoreProxy itemsForService:service accessGroup:accessGroup];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[items count]];    
    for (NSDictionary *attributes in items) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        [attrs setObject:[attributes objectForKey:kSecAttrService] forKey:@"Service"];
        [attrs setObject:[attributes objectForKey:kSecAttrAccount] forKey:@"Account"];
        [attrs setObject:[attributes objectForKey:kSecAttrAccessGroup] forKey:@"AccessGroup"];
        NSData *data = [attributes objectForKey:kSecValueData];
        NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        if (string) {
            [attrs setObject:string forKey:@"Value"];
        } else {
            [attrs setObject:data forKey:@"Value"];
        }
        [list addObject:attrs];
    }
    return [list description];
}

#pragma mark -

- (void)setKeyChainItem:(NSDictionary *)item {
    NSString *key = [item objectForKey:@"key"];
    NSString *value = [item objectForKey:@"value"];
    [self setString:value forKey:key];
}

- (void)setString:(NSString *)string forKey:(NSString *)key {
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (NSString *)stringForKey:(id)key {
    NSData *data = [self dataForKey:key];
    if (data) {
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return nil;
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    if (!key) {
        return;
    }
    if (!data) {
        [self removeItemForKey:key];
    } else {
        [itemsToUpdate setObject:data forKey:key];
    }
}

- (NSData *)dataForKey:(NSString *)key {
    NSData *data = [itemsToUpdate objectForKey:key];
    if (!data) {
        data = [KeyChainStoreProxy dataForKey:key service:service accessGroup:accessGroup];
    }
    return data;
}

- (void)removeItemForKey:(NSString *)key {
    if ([itemsToUpdate objectForKey:key]) {
        [itemsToUpdate removeObjectForKey:key];
    } else {
        [KeyChainStoreProxy removeItemForKey:key service:service accessGroup:accessGroup];
    }
}

#pragma mark -

- (void)removeAllItems {
    [itemsToUpdate removeAllObjects];
    [KeyChainStoreProxy removeAllItemsForService:service accessGroup:accessGroup];
}

#pragma mark -

- (void)synchronize {    
    for (NSString *key in itemsToUpdate) {
        [KeyChainStoreProxy setData:[itemsToUpdate objectForKey:key] forKey:key service:service accessGroup:accessGroup];
    }
}

@end
