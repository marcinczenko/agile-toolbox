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

- (void)testThatAppDelegateCreatesQuestionsDataSource
{
    EPAppDelegate* appDelegate = [[EPAppDelegate alloc]init];
    
    XCTAssertNil(appDelegate.questionsDataSource);
    
    [appDelegate application:self.doesNotMatter didFinishLaunchingWithOptions:self.doesNotMatter];
    
    XCTAssertNotNil(appDelegate.questionsDataSource);
    
    XCTAssertEqualObjects(NSStringFromClass([appDelegate.questionsDataSource class]), NSStringFromClass([EPQuestionsDataSource class]));
    
    XCTAssertEqualObjects(@"http://localhost:9001/items_json", appDelegate.questionsDataSource.connectionURL);
}

@end
