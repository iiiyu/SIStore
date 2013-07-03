//
//  TBStore.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-2.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "TBStore.h"

@implementation TBStore

+ (BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error
{
    // override
    return YES;
}

+ (void)deDupe
{
    // override
}

@end
