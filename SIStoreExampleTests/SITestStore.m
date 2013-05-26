//
//  SITestStore.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-5-25.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "SITestStore.h"
#import <CoreData+MagicalRecord.h>

@implementation SITestStore

+ (void)setupLocalStoreCompletionAndWait
{
	[self cleanUpIfNecessary];

    [self setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"TestDatabase.sqlite"];
}



+ (NSURL *)localStoreURL
{
    return [SITestStore urlForStoreName:@"TestDatabase.sqlite"];
}

#pragma mark - URL
+ (NSURL *) urlForStoreName:(NSString *)storeFileName
{
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    

        NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:storeFileName];
        if ([fm fileExistsAtPath:filepath])
        {
            return [NSURL fileURLWithPath:filepath];
        }

    
    //set default url
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:storeFileName]];
}

#pragma mark - Private

+ (void)cleanUpIfNecessary
{
	if ([NSPersistentStoreCoordinator MR_defaultStoreCoordinator] != nil) {
		[MagicalRecord cleanUp];
	}
}



#pragma mark - test store path
+ (void)setupCoreDataStackWithAutoMigratingSqliteStoreNamed:(NSString *)storeName
{
    if ([NSPersistentStoreCoordinator MR_defaultStoreCoordinator] != nil) return;
    
    NSPersistentStoreCoordinator *coordinator = [[self class] coordinatorWithAutoMigratingSqliteStoreNamed:storeName];
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:coordinator];
    
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:coordinator];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithAutoMigratingSqliteStoreNamed:(NSString *) storeFileName
{
    NSManagedObjectModel *model = [NSManagedObjectModel MR_defaultManagedObjectModel];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // get presistentStore
    
    NSDictionary *options = [[self class] autoMigrationOptions];
    NSURL *url = [SITestStore urlForStoreName:storeFileName];
    NSError *error = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathToStore = [url URLByDeletingLastPathComponent];
    
    BOOL pathWasCreated = [fileManager createDirectoryAtPath:[pathToStore path] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!pathWasCreated)
    {
        [MagicalRecord handleErrors:error];
    }
    
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:url
                                                        options:options
                                                          error:&error];
    if (!store && [MagicalRecord shouldDeleteStoreOnModelMismatch])
    {
        if ([[error domain] isEqualToString:NSCocoaErrorDomain] && [error code] == NSPersistentStoreIncompatibleVersionHashError)
        {
            // Could not open the database, so... kill it!
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            
            MRLog(@"Removed incompatible model version: %@", [url lastPathComponent]);
            
            // Try one more time to create the store
            store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:url
                                             options:options
                                               error:&error];
            if (store)
            {
                // If we successfully added a store, remove the error that was initially created
                error = nil;
            }
        }
        
        [MagicalRecord handleErrors:error];
    }
    
    
    [coordinator MR_addAutoMigratingSqliteStoreNamed:storeFileName];
    
    //HACK: lame solution to fix automigration error "Migration failed after first pass"
    if ([[coordinator persistentStores] count] == 0)
    {
        [coordinator performSelector:@selector(MR_addAutoMigratingSqliteStoreNamed:) withObject:storeFileName afterDelay:0.5];
    }
    
    return coordinator;
}


+ (NSDictionary *) autoMigrationOptions;
{
    // Adding the journalling mode recommended by apple
    NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
    [sqliteOptions setObject:@"WAL" forKey:@"journal_mode"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption,
                             nil];
    return options;
}


@end
