//
//  EPQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPQuestionsTableViewController.h"
#import "EPAddQuestionViewController.h"
#import "EPQuestionsDataSourceProtocol.h"

#import "EPPostmanProtocol.h"

#import "EPQuestionsSmartTableViewCell.h"

#import <objc/runtime.h>


@interface EPQuestionsTableViewControllerTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController* vc;
@property (nonatomic,strong) id partialVCMock;
@property (nonatomic,readonly) id doesNotMatter;

@end


@implementation EPQuestionsTableViewControllerTests
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

- (void)disableViewPropertyForTheVC:(EPQuestionsTableViewController *)vc
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
    self.vc = [[EPQuestionsTableViewController alloc] init];
}

- (void)tearDown
{
    self.vc = nil;
    self.partialVCMock = nil;
}

- (void)testQATQuestionTableViewControllerHasPropertyForDataSource
{
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    self.vc.questionsDataSource = dataSourceMock;
}

- (void)testQATQuestionTableViewControllerHasPropertyForPostmanService
{
    id postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    
    self.vc.postman = postmanMock;
}


- (void)testThatTheRightCellForTheRightRowIsReturned
{    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    [[[questionsDataSourceMock stub] andReturn:@"Question 1"] questionAtIndex:0];

    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([EPQuestionsSmartTableViewCell class])];
    
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
    
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    [dataSourceMock setExpectationOrderMatters:YES];
    [[dataSourceMock expect] setDelegate:self.vc];
    [[dataSourceMock expect] fetch];
    
    self.vc.questionsDataSource = dataSourceMock;
    
    [self.vc viewDidLoad];
    
    [dataSourceMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfThePostman
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    [[postmanMock expect] setDelegate:self.vc];
    
    self.vc.postman = postmanMock;
    
    [self.vc viewDidLoad];
    
    [postmanMock verify];
}

- (void)testThatViewSetsTheReferenceToDataSourceToNilWhenMemoryWarningReceived
{
    
    [self disableViewPropertyForTheVC:self.vc];
    
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    self.vc.questionsDataSource = dataSourceMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.questionsDataSource);
}

- (void)testThatViewSetsTheReferenceToPostmanToNilWhenMemoryWarningReceived
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    
    self.vc.postman = postmanMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.postman);
}

//- (void)testReloadingTheTableWhenQuestionsAreDownloaded
//{
//    EPQuestionsTableViewController* vc = [[EPQuestionsTableViewController alloc] init];
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
    XCTAssertEqual(1,(int)[self.vc numberOfSectionsInTableView:self.doesNotMatter]);
}

- (void)testThatNumberOfRowsInTheSectionReflectsNumberOfItemsInTheDataSource
{
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfRows = [self magicNumber:5];
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] length];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    XCTAssertEqual(self.vc.questionsDataSource.length, (NSUInteger)[self.vc tableView:self.doesNotMatter numberOfRowsInSection:0]);
    
    [questionsDataSourceMock verify];
}

- (void)testThatCurrentViewControllerIsSetToBeDelegateOfTheDestinationControllerOnPerformingAddQuestionSegue
{ 
    id navigationControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    id destinationController = [OCMockObject mockForClass:[EPAddQuestionViewController class]];
    [[[navigationControllerMock stub] andReturn:destinationController] topViewController];
    [[destinationController expect] setDelegate:self.vc];
    id segueMock = [OCMockObject mockForClass:[UIStoryboardSegue class]];
    [[[segueMock stub] andReturn:@"AddQuestion"] identifier];
    [[[segueMock stub] andReturn:navigationControllerMock] destinationViewController];
    
    [self.vc prepareForSegue:segueMock sender:self.doesNotMatter];
    
    [destinationController verify];
    [segueMock verify];
}

- (NSArray*)indexPathsFrom:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger row=fromIndex; row<=toIndex; row++) {
        [array addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return array;
}

- (void) testThatCorrectRowsAreInsertedToTheTableWhenDataSourceDelegateIsCalled
{
    NSArray* expectedIndexes = [self indexPathsFrom:0 to:9];
    
    id questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] beginUpdates];
    [[tableViewMock expect] insertRowsAtIndexPaths:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [expectedIndexes isEqualToArray:obj];
    }] withRowAnimation:UITableViewRowAnimationNone];
    [[tableViewMock expect] endUpdates];
    [[[questionsTableViewControllePartialMock stub] andReturn:tableViewMock] tableView];
    
    [self.vc updateTableViewRowsFrom:0 to:9];
    
    [tableViewMock verify];
}

- (void)testThatAppropriatePostmanMethodIsCalledWhenNewQuestionIsAdded
{
    NSString * addedQuestion = @"New Question";
    id postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    [[postmanMock expect] post:addedQuestion];

    self.vc.postman = postmanMock;

    [self.vc questionAdded:addedQuestion];

    [postmanMock verify];
}

- (void)testThatDataSourceDownloadIsForcedWhenPostmanConfirmesThatANewQuestionHasBeenAddedSuccessfully
{
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    [[questionsDataSourceMock expect] downloadData];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    [self.vc postDelivered];
    
    [questionsDataSourceMock verify];
}

@end
