//
//  QATAppDelegateTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATAppDelegate.h"

@interface QATAppDelegateTests : XCTestCase

@end

@implementation QATAppDelegateTests

- (id)doesNotMatter
{
    return nil;
}

- (void)testThatAppDelegateCreatesQuestionsDataSource
{
    QATAppDelegate* appDelegate = [[QATAppDelegate alloc]init];
    
    XCTAssertNil(appDelegate.questionsDataSource);
    
    [appDelegate application:self.doesNotMatter didFinishLaunchingWithOptions:self.doesNotMatter];
    
    XCTAssertNotNil(appDelegate.questionsDataSource);
    
    XCTAssertEqualObjects(NSStringFromClass([appDelegate.questionsDataSource class]), NSStringFromClass([QATQuestionsDataSource class]));
    
    XCTAssertEqualObjects(@"http://localhost:9001/items_json", appDelegate.questionsDataSource.connectionURL);
}

@end
