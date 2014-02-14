//
//  SIStore.m
//
//  Created by Kevin Cao on 12-9-26.
//  Copyright (c) 2012年 sumi-sumi.com. All rights reserved.
//

#import "SIStore.h"
#import <SIAlertView.h>
#import <CoreData+MagicalRecord.h>

NSString *const SIDefaultStoreFileName = @"CoreDataStore";
NSString *const SIUseLocalStoreKey = @"SIUseLocalStoreKey";
NSString *const SINeedDeDupeKey = @"SINeedDeDupeKey";

NSString *const SIICloudDidBecomeAvailableNotification = @"SIICloudDidBecomeAvailableNotification";
NSString *const SIICloudDidBecomeUnavailableNotification = @"SIICloudDidBecomeUnavailableNotification";
NSString *const SISetupDidFinishNotification = @"SISetupDidFinishNotification";
NSString *const SIMigrateDidFinishNotification = @"SIMigrateDidFinishNotification";

static NSString *const SIICloudIsUnavailableKey = @"iCloud is Unavailable";
static NSString *const SIICloudSyncFailedKey = @"iCloud Sync Failed";
static NSString *const SIICloudReadonlyModeKey = @"Readonly mode";
static NSString *const SIICloudRetryKey = @"Retry";
static NSString *const SIICloudSwitchToLocalKey = @"Switch to local";
static NSString *const SIICloudNeedEnableICloudKey = @"You need enable iCloud documents within system settings, or you can switch to local.";

static SIICloudStoreState __iCloudStoreState = SIICloudStoreStateUnknown;
static void(^ __completion)(void) = nil;
static id __iCloudStateNotificationObserver = nil;
static NSUInteger __retryTimes = 0;
BOOL __isMigrating = NO;

SIStoreFallbackPolicy __fallbackPolicy = SIStoreFallbackPolicyMigrate;
BOOL __readonlyModeEnabled = NO;

@interface SIStore ()

+ (void)setICloudStoreState:(SIICloudStoreState)state;

@end

@implementation SIStore

+ (BOOL)isUsingLocalStore;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SIUseLocalStoreKey];
}

+ (SIICloudStoreState)iCloudStoreState
{
	return __iCloudStoreState;
}

+ (void)setICloudStoreState:(SIICloudStoreState)state
{
	@synchronized(self) {
        __iCloudStoreState = state;
    }
}

+ (SIStoreFallbackPolicy)fallbackPolicy
{
    return __fallbackPolicy;
}

+ (void)setFallbackPolicy:(SIStoreFallbackPolicy)fallbackPolicy
{
    __fallbackPolicy = fallbackPolicy;
}

+ (BOOL)readonlyModeEnabled
{
    return __readonlyModeEnabled;
}

+ (void)setReadonlyModeEnabled:(BOOL)enabled
{
    __readonlyModeEnabled = enabled;
}

+ (void)checkICloudAvailabilityCompletion:(void (^)(BOOL available))completion
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager respondsToSelector:@selector(ubiquityIdentityToken)]) {
		if (completion) {
			completion([fileManager ubiquityIdentityToken] != nil);
		}
	} else {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(queue, ^{
			NSURL *cloudURL = [NSPersistentStore MR_cloudURLForUbiqutiousContainer:nil];
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (completion) {
					completion(cloudURL != nil);
				}
			});
		});
	}
}

+ (void)setupStoreUsingDefaultLocationCompletion:(void (^)(void))completion
{
	BOOL useLocalStore = [SIStore isUsingLocalStore];
	if (useLocalStore) {
		[self setupLocalStoreCompletion:^{
			if (completion) {
				completion();
			}
		}];
	} else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[self setupICloudStoreCompletion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			if (completion) {
				completion();
			}
		}];
	}
}

+ (void)setupLocalStoreCompletion:(void (^)(void))completion
{
	[self cleanUpIfNecessary];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SIUseLocalStoreKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (__iCloudStateNotificationObserver) {
		[[NSNotificationCenter defaultCenter] removeObserver:__iCloudStateNotificationObserver];
	}
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[MagicalRecord defaultStoreName]];
        if (!__isMigrating && [[NSUserDefaults standardUserDefaults] boolForKey:SINeedDeDupeKey]) {
            [self deDupe];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SINeedDeDupeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
		dispatch_sync(dispatch_get_main_queue(), ^{
			if (completion) {
				completion();
			}
            [[NSNotificationCenter defaultCenter] postNotificationName:SISetupDidFinishNotification object:self];
		});
	});
}

+ (void)setupICloudStoreCompletion:(void (^)(void))completion
{
	[self cleanUpIfNecessary];
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:SIUseLocalStoreKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSString *defaultName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];
    if (defaultName == nil) {
        defaultName = SIDefaultStoreFileName;
    }
	
	[self setICloudStoreState:SIICloudStoreStateUnknown];
    
	[MagicalRecord setupCoreDataStackWithiCloudContainer:nil
										  contentNameKey:[self iCloudContentNameKey]
										 localStoreNamed:[self iCloudStoreName]
								 cloudStorePathComponent:@"Logs"
											  completion:^{
												  [self updateICloudStoreState];
												  [self handleICloudResultWithCompletion:completion];
											  }];
}

+ (void)switchStore:(BOOL)useLocalStore completion:(void (^)(void))completion
{
	if (useLocalStore) {
        [self setupLocalStoreCompletion:^{
            if (completion) {
                completion();
            }
        }];
    } else {
        [self setupICloudStoreCompletion:^{
            if (completion) {
                completion();
            }
        }];
    }
}

+ (void)migrateStore:(BOOL)useLocalStore completion:(void (^)(void))completion
{
    __isMigrating = YES;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SINeedDeDupeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    void(^migrateCompletion)(void) = ^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SINeedDeDupeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        __isMigrating = NO;
        if(completion) {
            completion();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SIMigrateDidFinishNotification object:self];
    };
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(useLocalStore) {
        [self setupLocalStoreCompletion:^{
            if([fileManager fileExistsAtPath:[[self iCloudStoreURL] path]]) {
                NSLog(@"Begin migrating iCloud to Local.");
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    NSError *error = nil;
                    BOOL success = [self seedStore:[NSPersistentStore MR_defaultPersistentStore]
                          withPersistentStoreAtURL:[self iCloudStoreURL]
                                             error:&error];
                    if(success) {
                        // preserve iCloud store
                    } else {
                        NSLog(@"Can't migrate iCloud to Local. Error: %@", error);
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        migrateCompletion();
                    });
                });
            } else {
                migrateCompletion();
            }
        }];
    } else {
        [self setupICloudStoreCompletion:^{
            if([fileManager fileExistsAtPath:[[self localStoreURL] path]]) {
                if([self iCloudStoreState] == SIICloudStoreStateNormal) {
                    NSLog(@"Begin migrating Local to iCloud.");
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        NSError *error = nil;
                        BOOL success = [self seedStore:[NSPersistentStore MR_defaultPersistentStore]
                              withPersistentStoreAtURL:[self localStoreURL]
                                                 error:&error];
                        if(success) {
                            [self deDupe];
                            // remove Local store
                            if(![fileManager removeItemAtPath:[[self localStoreURL] path] error:&error]) {
                                NSLog(@"Can't delete local store. Error: %@", error);
                            }
                        } else {
                            NSLog(@"Can't migrate Local to iCloud. Error: %@", error);
                        }
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            migrateCompletion();
                        });
                    });
                } else {
                    NSLog(@"Can't migrate Local to iCloud. Error: iCloud error.");
                    migrateCompletion();
                }
            } else {
                migrateCompletion();
            }
        }];
    }
}

+ (BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error
{
    // override
    return YES;
}

+ (void)deDupe
{
    // override
}

+ (NSString *)iCloudContentNameKey
{
	NSString *defaultName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];
    if (defaultName == nil) {
        defaultName = SIDefaultStoreFileName;
    }
	return defaultName;
}

+ (NSString *)iCloudStoreName
{
	return [NSString stringWithFormat:@"%@%@", [self iCloudContentNameKey], @"iCloud"];
}

+ (NSURL *)localStoreURL
{
	return [NSPersistentStore MR_urlForStoreName:[MagicalRecord defaultStoreName]];
}

+ (NSURL *)iCloudStoreURL
{
    NSURL *result = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSString *appDocDir = [[[[NSFileManager defaultManager] URLsForDirectory: NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] relativePath];
        NSArray *arrayFiles = [[self class] arrayFilePathsWith:appDocDir];
        for (NSString *filePath in arrayFiles) {
            if ([[filePath lastPathComponent] isEqualToString:[self iCloudStoreName]]){
                result = [NSURL fileURLWithPath:filePath];
            }
        }
    }else{
        result  = [NSPersistentStore MR_urlForStoreName:[self iCloudStoreName]];
    }
    
    return result;
}

#pragma mark - Private

+ (void)cleanUpIfNecessary
{
	if ([NSPersistentStoreCoordinator MR_defaultStoreCoordinator] != nil) {
		[MagicalRecord cleanUp];
	}
}

+ (void)updateICloudStoreState
{
	if (![NSPersistentStore MR_defaultPersistentStore]) {
		[self setICloudStoreState:SIICloudStoreStateError];
	} else if (![MagicalRecord isICloudEnabled]) {
		[self setICloudStoreState:SIICloudStoreStateReadOnly];
	} else {
		[self setICloudStoreState:SIICloudStoreStateNormal];
	}
}

+ (void)handleICloudResultWithCompletion:(void (^)(void))completion
{
	switch ([self iCloudStoreState]) {
		case SIICloudStoreStateUnknown:
		case SIICloudStoreStateError:
		{
            [self cleanUpIfNecessary];
            if (__retryTimes <= 0) {
                // delete iCloud local store
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                if ([fileManager fileExistsAtPath:[[self iCloudStoreURL] path]]) {
                    NSError *error = nil;
                    NSURL *url = [NSPersistentStore MR_urlForStoreName:[self iCloudStoreName]];
                    NSLog(@"Delete iCloud Store: %@", url);
                    NSFileManager *fileManager = [[NSFileManager alloc] init];
                    if (![fileManager removeItemAtURL:url error:&error]) {
                        NSLog(@"Can't delete iCloud Store: %@", error);
                    }
                }
                
                // and try again
                __retryTimes++;
                [self setupICloudStoreCompletion:completion];
            } else {
                __completion = [completion copy];
				[self alertError];
                
                // reset retry times
                __retryTimes = 0;
            }
		}
			break;
		case SIICloudStoreStateReadOnly:
		{
			__completion = [completion copy];
			[self alertReadOnly];
		}
			break;
		case SIICloudStoreStateNormal:
		default:
        {
            void (^setupCompletion)(void) = ^{
                if (completion) {
                    completion();
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:SISetupDidFinishNotification object:self];
            };
            
            if (!__isMigrating && [[NSUserDefaults standardUserDefaults] boolForKey:SINeedDeDupeKey]) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [self deDupe];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SINeedDeDupeKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        setupCompletion();
                    });
                });
            } else {
                setupCompletion();
            }
        }
			break;
	}
	if ([self iCloudStoreState] == SIICloudStoreStateReadOnly || [self iCloudStoreState] == SIICloudStoreStateNormal) {
		__iCloudStateNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
																							  object:[UIApplication sharedApplication]
																							   queue:[NSOperationQueue mainQueue]
																						  usingBlock:^(NSNotification *note) {
																							  [self checkICloudAvailabilityCompletion:^(BOOL available) {
																								  if ([self iCloudStoreState] == SIICloudStoreStateNormal) {
																									  if (!available) {
																										  [self setICloudStoreState:SIICloudStoreStateReadOnly];
																										  [[NSNotificationCenter defaultCenter] postNotificationName:SIICloudDidBecomeUnavailableNotification object:self];
																									  }
																								  } else if ([self iCloudStoreState] == SIICloudStoreStateReadOnly) {
																									  if (available) {
																										  [self setICloudStoreState:SIICloudStoreStateNormal];
																										  [[NSNotificationCenter defaultCenter] postNotificationName:SIICloudDidBecomeAvailableNotification object:self];
																									  }
																								  }
																							  }];
																						  }];
	}
}

#pragma mark - Alert

+ (void)alertError
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[self localizedStringForKey:SIICloudSyncFailedKey withDefault:@"iCloud Sync Failed"]
                                                        message:nil];
    [alertView addButtonWithTitle:[self localizedStringForKey:SIICloudRetryKey withDefault:@"Retry"]
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              // retry iCloud
                              [SIStore setupICloudStoreCompletion:[__completion copy]];
                              __completion = nil;
                          }];
    [alertView addButtonWithTitle:[self localizedStringForKey:SIICloudSwitchToLocalKey withDefault:@"Switch to local"]
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              // switch to local base on policy setting
                              if ([self fallbackPolicy] == SIStoreFallbackPolicyMigrate) {
                                  [SIStore migrateStore:YES completion:[__completion copy]];
                              } else {
                                  [SIStore setupLocalStoreCompletion:[__completion copy]];
                              }
                              __completion = nil;
                          }];
    [alertView show];
}

+ (void)alertReadOnly
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[self localizedStringForKey:SIICloudIsUnavailableKey withDefault:@"iCloud is Unavailable"]
                                                        message:[self localizedStringForKey:SIICloudNeedEnableICloudKey withDefault:@"You need enable iCloud documents within system settings, or you can switch to local."]];
    [alertView addButtonWithTitle:[self localizedStringForKey:SIICloudReadonlyModeKey withDefault:@"Readonly mode"]
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              // readonly
                              if (__completion) {
                                  __completion();
                              }
                              __completion = nil;
                          }];
    [alertView addButtonWithTitle:[self localizedStringForKey:SIICloudSwitchToLocalKey withDefault:@"Switch to local"]
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              // switch to local base on policy setting
                              if ([self fallbackPolicy] == SIStoreFallbackPolicyMigrate) {
                                  [SIStore migrateStore:YES completion:[__completion copy]];
                              } else {
                                  [SIStore setupLocalStoreCompletion:[__completion copy]];
                              }
                              __completion = nil;
                          }];
    [alertView show];
}

#pragma mark - Helper

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    //default settings
    BOOL useAllAvailableLanguages = YES;
    
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SIStore" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
        if (useAllAvailableLanguages)
        {
            //manually select the desired lproj folder
            for (NSString *language in [NSLocale preferredLanguages])
            {
                if ([[bundle localizations] containsObject:language])
                {
                    bundlePath = [bundle pathForResource:language ofType:@"lproj"];
                    bundle = [NSBundle bundleWithPath:bundlePath];
                    break;
                }
            }
        }
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

+ (NSArray *)arrayFilePathsWith:(NSString *)documentPath
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSError *error;
    NSArray *tempArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:&error];
    for (NSString *fileName in tempArray) {
        NSString *fullPath = [documentPath stringByAppendingFormat:@"/%@",fileName];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                [result addObjectsFromArray:[[self class] arrayFilePathsWith:fullPath]];
            }else{
                [result addObject:fullPath];
            }
        }
    }
    return result;
}

@end
