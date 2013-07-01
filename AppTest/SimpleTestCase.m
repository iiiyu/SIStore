//
//  SimpleTestCase.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-5-27.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "SimpleTestCase.h"
#import <OCMock.h>

@implementation SimpleTestCase


- (void)testSimplePass {
	// Another test
}

- (void)testSimpleFail {
	GHAssertTrue(NO, nil);
}


- (void)testOCMockPass {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"mocktest", returnValue,
                         @"Should have returned the expected string.");
}

- (void)testOCMockFail {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"thisIsTheWrongValueToCheck",
                         returnValue, @"Should have returned the expected string.");
}

@end
