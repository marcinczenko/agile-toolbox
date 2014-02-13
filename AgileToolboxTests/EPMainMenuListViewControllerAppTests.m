//
//  AgileToolboxTests.m
//  AgileToolboxTests
//
//  Created by Marcin Czenko on 4/12/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EPMainMenuListViewController.h"
#import "EPAppDelegate.h"
#import "EPMenuListSmartTableViewCell.h"

@interface EPMainMenuListViewControllerAppTests : XCTestCase

@property (nonatomic,strong) EPMainMenuListViewController *vc;

@end


@implementation EPMainMenuListViewControllerAppTests
@synthesize vc=_vc;

- (id)doesNotMatter
{
    return nil;
}

- (void)setUp
{
    [super setUp];
    
    UIApplication *application = [UIApplication sharedApplication];
    EPAppDelegate *appDelegate = [application delegate];
    NSLog(@"===== AFTER accesing application delegate");
    UIWindow *window = [appDelegate window];
    UINavigationController* navigationController = (UINavigationController*)[window rootViewController];
    self.vc = (EPMainMenuListViewController*)[navigationController topViewController];
}

- (void)tearDown
{
    self.vc = nil;
    
    [super tearDown];
}

- (void)testThatMainMenuViewControllerIsNotNil
{
    XCTAssertNotNil(self.vc,@"ViewController is not set!");
}

- (void)testThatAccessibilityLabelIsSetUpAfterViewIsLoaded
{
    XCTAssertNotNil(self.vc.view,@"View Controller's view is not set !");
    XCTAssertEqualObjects(self.vc.view.accessibilityLabel,@"MenuList",@"Accesibility Lable for the associated view is not set.");
}

- (void)testNumberOfSectionsInTableViewReturnedByDataSource
{
    XCTAssertEqual(1,(int)[self.vc.tableView numberOfSections],@"Wrong number of sections returned!");
}

- (void)testNumberOfRowsInTableViewReturnedByDataSourceDelegate
{
    XCTAssertEqual(2,(int)[self.vc.tableView numberOfRowsInSection:0],@"Wrong number of rows returned!");
}

- (void)testThatTheCellForTheQACellIsSetupCorrectly
{
    NSIndexPath * qaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell* cell = [self.vc.tableView cellForRowAtIndexPath:qaIndexPath];
    
    XCTAssertEqualObjects([EPMenuListSmartTableViewCell cellIdentifier], cell.reuseIdentifier);
    XCTAssertEqualObjects(@"Q&A", cell.textLabel.text);
    XCTAssertEqualObjects(cell.accessibilityLabel, cell.textLabel.text);
}

- (void)testThatQuestionsSegueIsPerformedRegardlessOfIndexPath
{
    id partialMock = [OCMockObject partialMockForObject:self.vc];
    
    [[partialMock expect] performSegueWithIdentifier:@"Questions" sender:self.vc];
    
    [self.vc tableView:self.doesNotMatter didSelectRowAtIndexPath:self.doesNotMatter];
    
    [partialMock verify];
}

@end
