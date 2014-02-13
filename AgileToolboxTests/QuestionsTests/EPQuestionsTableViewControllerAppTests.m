//
//  EPQuestionsTableViewControllerAppTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPAppDelegate.h"

#import "EPMainMenuListViewController.h"
#import "EPQuestionsTableViewController.h"
#import "EPQuestionsDataSource.h"
#import "EPQuestionPostman.h"

@interface EPQuestionsTableViewControllerAppTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController* vc;

@end


@implementation EPQuestionsTableViewControllerAppTests
@synthesize vc = _vc;

- (void)setUp
{
    [super setUp];
    
    UIApplication *application = [UIApplication sharedApplication];
    EPAppDelegate *appDelegate = [application delegate];
    UIWindow *window = [appDelegate window];
    UINavigationController* navigationController = (UINavigationController*)[window rootViewController];
    
    UIViewController *topViewController = navigationController.topViewController;
    
    if ([NSStringFromClass([topViewController class]) isEqualToString:NSStringFromClass([EPMainMenuListViewController class])]) {
        [topViewController performSegueWithIdentifier: @"Questions" sender:topViewController];
        topViewController = navigationController.topViewController;
    }
    
    self.vc = (EPQuestionsTableViewController*)topViewController;
}

- (void)tearDown
{
    self.vc = nil;
    
    [super tearDown];
}

- (void)testThatQuestionViewControllerIsNotNil
{
    XCTAssertNotNil(self.vc,@"ViewController is not set!");
}

- (void)testThatQuestionsDataSourceIsNotNilAndPointsToAnObjectOfTheAppropriateClass
{
    XCTAssertNotNil(self.vc.questionsDataSource,@"Questions Data Source is not set!");
    XCTAssertEqualObjects(NSStringFromClass([self.vc.questionsDataSource class]), NSStringFromClass([EPQuestionsDataSource class]));
}

- (void)testThatPostmanIsNotNilAndPointsToAnObjectOfTheAppropriateClass
{
    XCTAssertNotNil(self.vc.postman,@"Postman is not set!");
    XCTAssertEqualObjects(NSStringFromClass([self.vc.postman class]), NSStringFromClass([EPQuestionPostman class]));
}

@end
