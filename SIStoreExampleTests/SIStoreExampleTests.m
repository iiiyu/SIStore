//
//  SIStoreExampleTests.m
//  SIStoreExampleTests
//
//  Created by ChenYu Xiao on 13-5-25.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "SIStoreExampleTests.h"
#import "SITestStore.h"
#import "Task.h"
#import <CoreData+MagicalRecord.h>

@implementation SIStoreExampleTests

- (void)setUp
{
    [super setUp];
    
    [SITestStore setupLocalStoreCompletionAndWait];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//- (void)testExample
//{
//    STFail(@"Unit tests are not implemented yet in SIStoreExampleTests");
//}


- (void)testInsertDB
{
    Task *one = [Task MR_createEntity];
    one.content = @"Test";
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"content = %@", @"Test"];
    
    Task *newOne = [Task MR_findFirstWithPredicate:predicate];

    STAssertEqualObjects(one.content, newOne.content, @"hhh");
  
}

@end
