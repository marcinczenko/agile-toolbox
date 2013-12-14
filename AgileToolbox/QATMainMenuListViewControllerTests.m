//
//  QATMainMenuListViewControllerTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATMainMenuListViewController.h"
#import "QATMenuListSmartTableViewCell.h"

@interface QATMainMenuListViewControllerTests : XCTestCase

@property (nonatomic,strong) QATMainMenuListViewController* viewController;

@property (readonly) id doesNotMatter;

@end


@implementation QATMainMenuListViewControllerTests

@synthesize viewController = _viewController;

- (id)doesNotMatter
{
    return nil;
}

- (void) setUp
{
    self.viewController = [[QATMainMenuListViewController alloc] init];
}

- (void)testThatAccessibilityLabelIsSetUpAfterViewIsLoaded
{
    [self.viewController viewDidLoad];
    
    // UIViewController loads view when we first access the view property.
    // Suprisingly it knows how to find it in story board file even in logic test.
    // I would expect this has to be tested in application logic tests, but if it
    // works, let it be :).
    XCTAssertNotNil(self.viewController.view,@"View Controller's view is not set !");
    XCTAssertEqualObjects(self.viewController.view.accessibilityLabel,@"MenuList",@"Accesibility Lable for the associated view is not set.");
}

- (void)testNumberOfSectionsInTableViewReturnedByDataSource
{
    XCTAssertEqual(1,[self.viewController numberOfSectionsInTableView:self.doesNotMatter],@"Wrong number of sections returned!");
}

- (void)testNumberOfRowsInTableViewReturnedByDataSourceDelegate
{
    XCTAssertEqual(2,[self.viewController tableView:self.doesNotMatter numberOfRowsInSection:0],@"Wrong number of rows returned!");
}

- (void)testThatTheCellForTheQACellIsSetupCorrectly
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATMenuListSmartTableViewCell class])];
    
    id textLabelMock = [OCMockObject mockForClass:[UILabel class]];
    
    [[textLabelMock expect] setText:@"Q&A"];
    [[[textLabelMock stub] andReturn:@"Q&A"] text];
    
    [[[tableViewCellMock stub] andReturn:textLabelMock] textLabel];
    [[tableViewCellMock expect] setAccessibilityLabel:@"Q&A"];
    
    [self.viewController tableView:tableViewMock cellForRowAtIndexPath:self.doesNotMatter];
    
    [textLabelMock verify];
    [tableViewCellMock verify];
    [tableViewMock verify];
}

- (void)testThatQuestionsSegueIsPerformedRegardlessOfIndexPath
{
    id partialMock = [OCMockObject partialMockForObject:self.viewController];
    
    [[partialMock expect] performSegueWithIdentifier:@"Questions" sender:self.viewController];
    
    [self.viewController tableView:self.doesNotMatter didSelectRowAtIndexPath:self.doesNotMatter];
    
    [partialMock verify];
}

@end
