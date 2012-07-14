//
//  QATAppDelegateTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATAppDelegate.h"

@interface QATAppDelegateTests : SenTestCase

@end

@implementation QATAppDelegateTests

- (id)doesNotMatter
{
    return nil;
}

- (void)testThatAppDelegateCreatesQuestionsDataSource
{
    QATAppDelegate* appDelegate = [[QATAppDelegate alloc]init];
    
    STAssertNil(appDelegate.questionsDataSource,nil);
    
    [appDelegate application:self.doesNotMatter didFinishLaunchingWithOptions:self.doesNotMatter];
    
    STAssertNotNil(appDelegate.questionsDataSource,nil);
    
    STAssertEqualObjects(NSStringFromClass([appDelegate.questionsDataSource class]), NSStringFromClass([QATQuestionsDataSource class]),nil);
    
    STAssertEqualObjects(@"https://quantumagiletoolbox-dev.appspot.com/items_json", appDelegate.questionsDataSource.connectionURL,nil);
}

@end
