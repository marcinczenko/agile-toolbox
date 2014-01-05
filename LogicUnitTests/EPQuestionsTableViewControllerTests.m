//
//  EPQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPAppDelegate.h"
#import "EPMainMenuListViewController.h"

#import "EPQuestionsTableViewController.h"
#import "EPAddQuestionViewController.h"

#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSource.h"

#import "EPQuestionTableViewCell.h"

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

- (NSArray*)indexPathsFrom:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger row=fromIndex; row<=toIndex; row++) {
        [array addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return array;
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

- (void)testThatLoadingDataStatusIsSetToNOAfterInitialization
{
    XCTAssertEqual(NO, self.vc.isLoadingData);
}

-(void)testThatViewDidLoadTriggersFetchWhenDataSourceHasNoData
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 0;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    [[questionsDataSourceMock expect] setDelegate:self.vc];
    [[questionsDataSourceMock expect] fetch];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc viewDidLoad];
    
    [questionsDataSourceMock verify];
}

-(void)testThatLoadingDataStatusIsSetToYESWhenViewDidLoadTriggeredFetch
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 0;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    [[questionsDataSourceMock expect] setDelegate:self.vc];
    [[questionsDataSourceMock expect] fetch];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc viewDidLoad];
    
    XCTAssertTrue(self.vc.isLoadingData);
    
    [questionsDataSourceMock verify];
}

-(void)testThatViewDidLoadDoesNotTriggerFetchWhenDataSourceAlreadyHasData
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 1;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    [[questionsDataSourceMock expect] setDelegate:self.vc];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc viewDidLoad];
    
    XCTAssertFalse(self.vc.isLoadingData);
    
    [questionsDataSourceMock verify];
}

// LEARNING
// this is just an example of a bad (and stupid) unit test. Do not test controllers in such a way.
// Create thin controllers instead and test them at the acceptance level.
-(void)testThatScrollingTriggersTheFetch
{
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 10;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    BOOL yesValue = YES;
    BOOL noValue = NO;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(yesValue)] hasMoreQuestionsToFetch];
    [[questionsDataSourceMock expect] questionAtIndex:9];
    [[questionsDataSourceMock expect] fetch];
    
    id questionTableViewControllerMock = [OCMockObject partialMockForObject:self.vc];
    [[[questionTableViewControllerMock stub] andReturnValue:OCMOCK_VALUE(yesValue)] scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:OCMOCK_ANY];
    [[questionTableViewControllerMock expect] activateFetchingIndicatorForCell:OCMOCK_ANY];
    [[[questionTableViewControllerMock stub] andReturnValue:OCMOCK_VALUE(noValue)] totalContentHeightSmallerThanScreenSize];
    [[[questionTableViewControllerMock stub] andReturn:nil] fetchMoreTableViewCell];
     
    id uiApplicationMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[uiApplicationMock expect] setNetworkActivityIndicatorVisible:YES];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc tableView:self.doesNotMatter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
    [self.vc scrollViewDidScroll:self.doesNotMatter];
    
    [questionsDataSourceMock verify];
    [uiApplicationMock verify];
    
}

// LEARNING
// this is just an example of a bad (and stupid) unit test. Do not test controllers in such a way.
// Create thin controllers instead and test them at the acceptance level.
-(void)testThatScrollingTriggersTheFetch2
{
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 10;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    BOOL yesValue = YES;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(yesValue)] hasMoreQuestionsToFetch];
    [[questionsDataSourceMock expect] questionAtIndex:9];
    [[questionsDataSourceMock expect] fetch];
    
    CGPoint contentOffset = CGPointMake(0, 1000+50);
    CGRect frame = CGRectMake(0, 0, 320, 580);
    CGSize contentSize = CGSizeMake(320, 1580);
    UIEdgeInsets contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0);
    NSInteger numberOfSections = 1;
    CGRect rectForSection0 = CGRectMake(0, 0, 320, 580);

    id scrollViewMock = [OCMockObject mockForClass:[UIScrollView class]];
    [[[scrollViewMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    [[[scrollViewMock stub] andReturnValue:OCMOCK_VALUE(frame)] frame];
    [[[scrollViewMock stub] andReturnValue:OCMOCK_VALUE(contentSize)] contentSize];
    [[[scrollViewMock stub] andReturnValue:OCMOCK_VALUE(contentInset)] contentInset];
    
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(frame)] frame];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(contentSize)] contentSize];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(contentInset)] contentInset];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(numberOfSections)] numberOfSections];
    [[[tableViewMock stub] andReturnValue:OCMOCK_VALUE(rectForSection0)] rectForSection:0];
    [[[tableViewMock stub] andReturn:nil] cellForRowAtIndexPath:OCMOCK_ANY];
    
    id questionTableViewControllerMock = [OCMockObject partialMockForObject:self.vc];
    [[[questionTableViewControllerMock stub] andReturn:tableViewMock] tableView];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc tableView:self.doesNotMatter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
    [self.vc scrollViewDidScroll:scrollViewMock];
    
    [questionsDataSourceMock verify];
}

-(void)testThatViewDidLoadActivatesNetworkStatusIndicatorWhenFetchIsPerformed
{
    [self disableViewPropertyForTheVC:self.vc];
    
    id uiApplicationMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    
    [[uiApplicationMock expect] setNetworkActivityIndicatorVisible:YES];
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    NSUInteger numberOfQuestionsInDataSource = 0;
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfQuestionsInDataSource)] length];
    [[questionsDataSourceMock expect] setDelegate:self.vc];
    [[questionsDataSourceMock expect] fetch];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc viewDidLoad];
    
    [questionsDataSourceMock verify];
    [uiApplicationMock verify];
}

- (void)testThatQuestionTableCellIsRequestedForSectionIndex0
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[tableViewMock expect] dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                 forIndexPath:indexPath];
    
    [self.vc tableView:tableViewMock cellForRowAtIndexPath:indexPath];
    
    [tableViewMock verify];
}

- (void)testThatFetchMoreTableCellIsRequestedForSectionIndex1
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[tableViewMock expect] dequeueReusableCellWithIdentifier:@"FetchMore"
                                                 forIndexPath:indexPath];
    
    [self.vc tableView:tableViewMock cellForRowAtIndexPath:indexPath];
    
    [tableViewMock verify];
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

- (void)testThatNumberOfSectionsIsCorrect
{
    BOOL valueYES = YES;
    BOOL valueNO = NO;
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    [questionsDataSourceMock setExpectationOrderMatters:YES];
    [[[questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueYES)] hasMoreQuestionsToFetch];
    [[[questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    XCTAssertEqual(2,(int)[self.vc numberOfSectionsInTableView:self.doesNotMatter]);
    XCTAssertEqual(1,(int)[self.vc numberOfSectionsInTableView:self.doesNotMatter]);
    
    [questionsDataSourceMock verify];
}

- (void)testThatNumberOfRowsInTheSectionReflectsNumberOfItemsInTheDataSourceForSection0
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

- (void)testThatCorrectRowsAreInsertedToTheTableWhenDataSourceDelegateIsCalled
{
    NSArray* expectedIndexes = [self indexPathsFrom:0 to:EPQuestionsDataSource.pageSize-1];
    BOOL valueYES = YES;
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] hasMoreQuestionsToFetch];
    
    id questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] beginUpdates];
    [[tableViewMock expect] insertRowsAtIndexPaths:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [expectedIndexes isEqualToArray:obj];
    }] withRowAnimation:UITableViewRowAnimationNone];
    [[tableViewMock expect] endUpdates];
    [[[questionsTableViewControllePartialMock stub] andReturn:tableViewMock] tableView];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc updateTableViewRowsFrom:0 to:EPQuestionsDataSource.pageSize-1];
    
    [tableViewMock verify];
}

-(void)testThatTheFetchMoreCellIsDeletedWhenDataSourceDoesNotHaveAnyMoreDataToFetch
{
    NSArray* expectedIndexes = [self indexPathsFrom:0 to:EPQuestionsDataSource.pageSize-2];
    BOOL valueNO = NO;
    
    id questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    [[[questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
    
    id questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] beginUpdates];
    [[tableViewMock expect] insertRowsAtIndexPaths:expectedIndexes withRowAnimation:UITableViewRowAnimationNone];
    [[tableViewMock expect] numberOfSections];
    [[tableViewMock expect] contentInset];
    [[tableViewMock expect] frame];
    
    // we do not care which animation in this test - we just want to be sure
    // that the Fetch More cell is deleted.
    [[[tableViewMock expect] ignoringNonObjectArgs] deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:0];
    [[tableViewMock expect] endUpdates];
    [[[questionsTableViewControllePartialMock stub] andReturn:tableViewMock] tableView];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    [self.vc updateTableViewRowsFrom:0 to:EPQuestionsDataSource.pageSize-2];
    
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
    [[questionsDataSourceMock expect] fetchNew];
    
    self.vc.questionsDataSource = questionsDataSourceMock;
    
    [self.vc postDelivered];
    
    [questionsDataSourceMock verify];
}

@end
