//
//  LogicUnitTests.m
//  LogicUnitTests
//
//  Created by AtrBea on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogicUnitTests.h"
#import <OCMock/OCMock.h>

@implementation LogicUnitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testOCMockPass
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    NSString *returnValue = [mock lowercaseString];
    STAssertEqualObjects(@"mocktest", returnValue,
                         @"Should have returned the expected string.");
}

- (void)testExample
{
    STFail(@"Unit tests are not implemented yet in LogicUnitTests");
}

@end
