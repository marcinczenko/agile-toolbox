//
//  QATQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATQuestionsTableViewController.h"
#import "QATAddQuestionViewController.h"
#import "QATDataSourceProtocol.h"

#import "QATQuestionsSmartTableViewCell.h"

#import <objc/runtime.h>


@interface QATQuestionsTableViewControllerTests : SenTestCase

@property (nonatomic,strong) QATQuestionsTableViewController* vc;
@property (nonatomic,strong) id partialVCMock;
@property (nonatomic,readonly) id doesNotMatter;

@end


@implementation QATQuestionsTableViewControllerTests
@synthesize vc = _vc;
@synthesize partialVCMock = _partialVCMock;

- (id)doesNotMatter
{
    return nil;
}

- (NSInteger)magicNumber:(NSInteger)number
{
    return number;
}

- (void)disableViewPropertyForTheVC:(QATQuestionsTableViewController *)vc
{
    // Everywhere we access the view property we will return nil, so that the view
    // will not be instatiated in the logic unit tests. If we let it happen
    // the viewDidLoad may be invoked more than once, and it costs unnecessary time
    // for something we do not want to test here.
    self.partialVCMock = [OCMockObject partialMockForObject:vc];
    [[[self.partialVCMock stub] andReturn:nil] view];
}

- (void)setUp
{
    self.vc = [[QATQuestionsTableViewController alloc] init];
}

- (void)tearDown
{
    self.vc = nil;
    self.partialVCMock = nil;
}

- (void)testQATQuestionTableViewControllerHasPropertyForDataSource
{
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    
    self.vc.questionsDataSource = dataSourceMock;
}


- (void)testThatTheRightCellForTheRightRowIsReturned
{    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    [[[questionsDataSourceMock stub] andReturn:@"Question 1"] questionAtIndex:0];

    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATQuestionsSmartTableViewCell class])];
    
    id textLabelMock = [OCMockObject mockForClass:[UILabel class]];    
    [[textLabelMock expect] setText:@"Question 1"];
    
    [[[tableViewCellMock stub] andReturn:textLabelMock] textLabel];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    [self.vc tableView:tableViewMock cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [textLabelMock verify];
    [tableViewCellMock verify];
    [tableViewMock verify];
    [questionsDataSourceMock verify];
}

- (void)testTheViewRegistersItselfAsTheDelegateOfTheQuestionsDataSourceAndTriggersDataDownload
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    
    [dataSourceMock setExpectationOrderMatters:YES];
    [[dataSourceMock expect] setDelegate:self.vc];
    [[dataSourceMock expect] downloadData];
    
    self.vc.questionsDataSource = dataSourceMock;
    
    [self.vc viewDidLoad];
    
    [dataSourceMock verify];
}

//- (void)testReloadingTheTableWhenQuestionsAreDownloaded
//{
//    QATQuestionsTableViewController* vc = [[QATQuestionsTableViewController alloc] init];
//    
//    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
//    [[tableViewMock expect] reloadData];
//    
//    id partialMock = [OCMockObject partialMockForObject:vc];
//    [[[partialMock stub] andReturn:tableViewMock] tableView];
//    
//    [vc dataSoruceLoaded];
//    
//    [tableViewMock verify];
//    [partialMock verify];
//}

- (void)testThatNumberOfSectionsIsOne
{    
    STAssertEquals(1,[self.vc numberOfSectionsInTableView:self.doesNotMatter],nil);
}

- (void)testThatNumberOfRowsInTheSectionReflectsNumberOfItemsInTheDataSource
{
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    NSInteger numberOfRows = [self magicNumber:5];
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] length];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    STAssertEquals(self.vc.questionsDataSource.length, [self.vc tableView:self.doesNotMatter numberOfRowsInSection:0],nil);
    
    [questionsDataSourceMock verify];
}

- (void)testThatCurrentViewControllerIsSetToBeDelegateOfTheDestinationControllerOnPerformingAddQuestionSegue
{ 
    id navigationControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    id destinationController = [OCMockObject mockForClass:[QATAddQuestionViewController class]];
    [[[navigationControllerMock stub] andReturn:destinationController] topViewController];
    [[destinationController expect] setDelegate:self.vc];
    id segueMock = [OCMockObject mockForClass:[UIStoryboardSegue class]];
    [[[segueMock stub] andReturn:@"AddQuestion"] identifier];
    [[[segueMock stub] andReturn:navigationControllerMock] destinationViewController];
    
    [self.vc prepareForSegue:segueMock sender:self.doesNotMatter];
    
    [destinationController verify];
    [segueMock verify];
}


@end
