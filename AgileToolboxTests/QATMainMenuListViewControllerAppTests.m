//
//  AgileToolboxTests.m
//  AgileToolboxTests
//
//  Created by Marcin Czenko on 4/12/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "QATMainMenuListViewController.h"
#import "QATAppDelegate.h"
#import "QATMenuListSmartTableViewCell.h"

@interface QATMainMenuListViewControllerAppTests : SenTestCase

@property (nonatomic,strong) QATMainMenuListViewController *vc;

@end


@implementation QATMainMenuListViewControllerAppTests
@synthesize vc=_vc;

- (id)doesNotMatter
{
    return nil;
}

- (void)setUp
{
    [super setUp];
    
    UIApplication *application = [UIApplication sharedApplication];
    QATAppDelegate *appDelegate = [application delegate];
    NSLog(@"===== AFTER accesing application delegate");
    UIWindow *window = [appDelegate window];
    UINavigationController* navigationController = (UINavigationController*)[window rootViewController];
    self.vc = (QATMainMenuListViewController*)[navigationController topViewController];
}

- (void)tearDown
{
    self.vc = nil;
    
    [super tearDown];
}

- (void)testThatMainMenuViewControllerIsNotNil
{
    STAssertNotNil(self.vc,@"ViewController is not set!");
}

- (void)testThatAccessibilityLabelIsSetUpAfterViewIsLoaded
{
    STAssertNotNil(self.vc.view,@"View Controller's view is not set !");
    STAssertEqualObjects(self.vc.view.accessibilityLabel,@"MenuList",@"Accesibility Lable for the associated view is not set.");
}

- (void)testNumberOfSectionsInTableViewReturnedByDataSource
{
    STAssertEquals(1,[self.vc.tableView numberOfSections],@"Wrong number of sections returned!");
}

- (void)testNumberOfRowsInTableViewReturnedByDataSourceDelegate
{
    STAssertEquals(1,[self.vc.tableView numberOfRowsInSection:0],@"Wrong number of rows returned!");
}

- (void)testThatTheCellForTheQACellIsSetupCorrectly
{
    NSIndexPath * qaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell* cell = [self.vc.tableView cellForRowAtIndexPath:qaIndexPath];
    
    STAssertEqualObjects([QATMenuListSmartTableViewCell cellIdentifier], cell.reuseIdentifier,nil);
    STAssertEqualObjects(@"Q&A", cell.textLabel.text,nil);
    STAssertEqualObjects(cell.accessibilityLabel, cell.textLabel.text,nil);
}

- (void)testThatQuestionsSegueIsPerformedRegardlessOfIndexPath
{
    id partialMock = [OCMockObject partialMockForObject:self.vc];
    
    [[partialMock expect] performSegueWithIdentifier:@"Questions" sender:self.vc];
    
    [self.vc tableView:self.doesNotMatter didSelectRowAtIndexPath:self.doesNotMatter];
    
    [partialMock verify];
}

@end
