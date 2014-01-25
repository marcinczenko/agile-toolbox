//
//  EPAppDelegateTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPAppDelegate.h"

@interface EPAppDelegateTests : XCTestCase

@end

@implementation EPAppDelegateTests

- (id)doesNotMatter
{
    return nil;
}

- (void)testThatAppDelegateCreatesDependencyBoxForQuestionsTableViewController
{
    EPAppDelegate* appDelegate = [[EPAppDelegate alloc]init];
    
    XCTAssertNil(appDelegate.questionsTableViewControllerDependencyBox);
}

@end
