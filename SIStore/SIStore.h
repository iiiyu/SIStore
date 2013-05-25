//
//  SIStore.h
//
//  Created by Kevin Cao on 12-9-26.
//  Copyright (c) 2012年 sumi-sumi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SIDefaultStoreFileName;
extern NSString *const SIUseLocalStoreKey;
extern NSString *const SINeedDeDupeKey;

extern NSString *const SIICloudDidBecomeAvailableNotification;
extern NSString *const SIICloudDidBecomeUnavailableNotification;
extern NSString *const SISetupDidFinishNotification;
extern NSString *const SIMigrateDidFinishNotification;

typedef NS_ENUM(NSUInteger, SIICloudStoreState) {
    SIICloudStoreStateUnknown = 0,
	SIICloudStoreStateNormal,
	SIICloudStoreStateReadOnly,
	SIICloudStoreStateError
};

typedef NS_ENUM(NSUInteger, SIStoreFallbackPolicy) {
    SIStoreFallbackPolicyMigrate = 0,
    SIStoreFallbackPolicySwitch
};

@interface SIStore : NSObject

+ (BOOL)isUsingLocalStore;
+ (SIICloudStoreState)iCloudStoreState;

+ (SIStoreFallbackPolicy)fallbackPolicy;
+ (void)setFallbackPolicy:(SIStoreFallbackPolicy)fallbackPolicy;
+ (BOOL)readonlyModeEnabled;
+ (void)setReadonlyModeEnabled:(BOOL)enabled;

+ (void)checkICloudAvailabilityCompletion:(void (^)(BOOL available))completion;
+ (void)setupStoreUsingDefaultLocationCompletion:(void (^)(void))completion;
+ (void)setupLocalStoreCompletion:(void (^)(void))completion;
+ (void)setupICloudStoreCompletion:(void (^)(void))completion;
+ (void)switchStore:(BOOL)useLocalStore completion:(void (^)(void))completion;
+ (void)migrateStore:(BOOL)useLocalStore completion:(void (^)(void))completion;

// override
+ (BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error;
+ (void)deDupe;

+ (NSString *)iCloudContentNameKey;
+ (NSString *)iCloudStoreName;
+ (NSURL *)localStoreURL;
+ (NSURL *)iCloudStoreURL;

@end
