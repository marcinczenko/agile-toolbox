//
//  AgileToolboxTests.m
//  AgileToolboxTests
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgileToolboxTests.h"
#import <OCMock/OCMock.h>

@implementation AgileToolboxTests
@synthesize vc=_vc;

- (void)setUp
{
    [super setUp];
    
    UIApplication *application = [UIApplication sharedApplication];
    STAssertNotNil(application,@"application is nil!");
    QATAppDelegate *appDelegate = [application delegate];
    STAssertNotNil(appDelegate,@"appDelegate is nil!");
    UIWindow *window = [appDelegate window];
    STAssertNotNil(window,@"window is nil!");
    self.vc = (QATMainMenuListViewController*)[window rootViewController];
}

- (void)tearDown
{
    self.vc = nil;
    
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


- (void)testThatViewControllerIsntNil
{
    STAssertNotNil(self.vc,@"ViewController is not set!");
}

@end
