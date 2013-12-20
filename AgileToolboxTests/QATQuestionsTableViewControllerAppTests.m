//
//  QATQuestionsTableViewControllerAppTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATAppDelegate.h"

#import "QATMainMenuListViewController.h"
#import "QATQuestionsTableViewController.h"
#import "QATQuestionsDataSource.h"
#import "QATQuestionPostman.h"

@interface QATQuestionsTableViewControllerAppTests : XCTestCase

@property (nonatomic,strong) QATQuestionsTableViewController* vc;

@end


@implementation QATQuestionsTableViewControllerAppTests
@synthesize vc = _vc;

- (void)setUp
{
    [super setUp];
    
    UIApplication *application = [UIApplication sharedApplication];
    QATAppDelegate *appDelegate = [application delegate];
    UIWindow *window = [appDelegate window];
    UINavigationController* navigationController = (UINavigationController*)[window rootViewController];
    
    UIViewController *topViewController = navigationController.topViewController;
    
    if ([NSStringFromClass([topViewController class]) isEqualToString:NSStringFromClass([QATMainMenuListViewController class])]) {
        [topViewController performSegueWithIdentifier: @"Questions" sender:topViewController];
        topViewController = navigationController.topViewController;
    }
    
    self.vc = (QATQuestionsTableViewController*)topViewController;
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
    XCTAssertEqualObjects(NSStringFromClass([self.vc.questionsDataSource class]), NSStringFromClass([QATQuestionsDataSource class]));
}

- (void)testThatPostmanIsNotNilAndPointsToAnObjectOfTheAppropriateClass
{
    XCTAssertNotNil(self.vc.postman,@"Postman is not set!");
    XCTAssertEqualObjects(NSStringFromClass([self.vc.postman class]), NSStringFromClass([QATQuestionPostman class]));
}

@end
