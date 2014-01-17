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


@interface EPQuestionsTableViewControllerTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController* vc;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id postmanMock;
@property (nonatomic,strong) id navigationControllerMock;
@property (nonatomic,strong) id addQuestionController;
@property (nonatomic,strong) id segueMock;
@property (nonatomic,strong) id questionsTableViewControllePartialMock;

@property (nonatomic,readonly) id doesNotMatter;

@end


@implementation EPQuestionsTableViewControllerTests

BOOL valueYES = YES;
BOOL valueNO = NO;

- (id)doesNotMatter
{
    return nil;
}

- (NSInteger)magicNumber:(NSInteger)number
{
    return number;
}

- (void)disableViewPropertyForTheVC
{
    // Everywhere we access the view property we will return nil, so that the view
    // will not be instatiated in the logic unit tests. If we let it happen
    // the viewDidLoad may be invoked more than once, and it costs unnecessary time
    // for something we do not want to test here.
    [[[self.questionsTableViewControllePartialMock stub] andReturn:nil] view];
}

-(void)expectThatFetchResultsControllerHasNoData
{
    [[[self.fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
}

-(void)expectThatFetchResultsControllerHasSomeData
{
    [[[self.fetchedResultsControllerMock stub] andReturn:@[@"Some data"]] fetchedObjects];
}

- (void)expectThatDataSourceHasNoMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
}

- (void)expectThatDataSourceHasSomeMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueYES)] hasMoreQuestionsToFetch];
}

-(void)expectThatFetchResultsControllerWithNItems:(NSUInteger)numberOfRows
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0; i<numberOfRows; i++) {
        [array addObject:[NSNumber numberWithInt:i]];
    }
    
    [[[self.fetchedResultsControllerMock stub] andReturn:array] fetchedObjects];
}

-(void)mockTableView
{
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewMock] tableView];
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
    self.questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    self.fetchedResultsControllerMock = [OCMockObject mockForClass:[NSFetchedResultsController class]];
    self.questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    self.postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    self.navigationControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    self.addQuestionController = [OCMockObject mockForClass:[EPAddQuestionViewController class]];
    self.segueMock = [OCMockObject mockForClass:[UIStoryboardSegue class]];
}

- (void)testQATQuestionTableViewControllerHasPropertyForDataSource
{
    self.vc.questionsDataSource = self.questionsDataSourceMock;
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
    [self disableViewPropertyForTheVC];
    
    [self expectThatFetchResultsControllerHasNoData];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    [[self.questionsDataSourceMock expect] fetchOlderThan:-1];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    [self.vc viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

-(void)testThatLoadingDataStatusIsSetToYESWhenViewDidLoadTriggeredFetch
{
    [self disableViewPropertyForTheVC];
    
    [self expectThatFetchResultsControllerHasNoData];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    [[self.questionsDataSourceMock expect] fetchOlderThan:-1];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    [self.vc viewDidLoad];
    
    XCTAssertTrue(self.vc.isLoadingData);
    
    [self.questionsDataSourceMock verify];
}

-(void)testThatViewDidLoadDoesNotTriggerFetchWhenDataSourceAlreadyHasData
{
    [self disableViewPropertyForTheVC];
    
    [self expectThatFetchResultsControllerHasSomeData];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];

    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    [self.vc viewDidLoad];
    
    XCTAssertFalse(self.vc.isLoadingData);
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatQuestionTableCellIsRequestedForSectionIndex0
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [[self.tableViewMock expect] dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                 forIndexPath:indexPath];
    
    [self.vc tableView:self.tableViewMock cellForRowAtIndexPath:indexPath];
    
    [self.tableViewMock verify];
}

- (void)testThatFetchMoreTableCellIsRequestedForSectionIndex1
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [[self.tableViewMock expect] dequeueReusableCellWithIdentifier:@"FetchMore"
                                                 forIndexPath:indexPath];
    
    [self.vc tableView:self.tableViewMock cellForRowAtIndexPath:indexPath];
    
    [self.tableViewMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfThePostman
{
    [self disableViewPropertyForTheVC];
    
    [[self.postmanMock expect] setDelegate:self.vc];
    
    self.vc.postman = self.postmanMock;
    
    [self.vc viewDidLoad];
    
    [self.postmanMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfTheDataSource
{
    [self disableViewPropertyForTheVC];
    
    [self expectThatFetchResultsControllerHasSomeData];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    
    [self.vc viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}


- (void)testThatViewSetsTheReferenceToDataSourceToNilWhenMemoryWarningReceived
{
    [self disableViewPropertyForTheVC];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.questionsDataSource);
}

- (void)testThatViewSetsTheReferenceToPostmanToNilWhenMemoryWarningReceived
{
    [self disableViewPropertyForTheVC];
    
    self.vc.postman = self.postmanMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.postman);
}

- (void)testThatThereIsOnlyOneSectionWhenDataSourceHasNoMoreDataToFetch
{
    [self expectThatDataSourceHasNoMoreQuestionsToFetch];
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    XCTAssertEqual(1,(int)[self.vc numberOfSectionsInTableView:self.doesNotMatter]);
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatThereAreTwoSectionsWhenDataSourceHasSomeMoreDataToFetch
{
    [self expectThatDataSourceHasSomeMoreQuestionsToFetch];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    XCTAssertEqual(2,(int)[self.vc numberOfSectionsInTableView:self.doesNotMatter]);
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatNumberOfRowsInTheSectionReflectsNumberOfItemsInTheFetchedResultsController
{
    NSUInteger numberOfRows = [self magicNumber:5];
    
    [self expectThatFetchResultsControllerWithNItems:numberOfRows];
    
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    XCTAssertEqual(numberOfRows, (NSUInteger)[self.vc tableView:self.doesNotMatter numberOfRowsInSection:0]);
}

- (void)testThatCurrentViewControllerIsSetToBeDelegateOfTheDestinationControllerOnPerformingAddQuestionSegue
{
    [[[self.navigationControllerMock stub] andReturn:self.addQuestionController] topViewController];
    [[self.addQuestionController expect] setDelegate:self.vc];

    [[[self.segueMock stub] andReturn:@"AddQuestion"] identifier];
    [[[self.segueMock stub] andReturn:self.navigationControllerMock] destinationViewController];
    
    [self.vc prepareForSegue:self.segueMock sender:self.doesNotMatter];
    
    [self.addQuestionController verify];
    [self.segueMock verify];
}

-(void)testThatTheFetchMoreCellIsDeletedWhenDataSourceDoesNotHaveAnyMoreDataToFetch
{
    [self expectThatDataSourceHasNoMoreQuestionsToFetch];
    
    id appPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[appPartialMock expect] setNetworkActivityIndicatorVisible:NO];
    
    [self mockTableView];
    
    [[self.questionsTableViewControllePartialMock expect] deleteFetchMoreCell];
    [[self.tableViewMock expect] endUpdates];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    [self.vc controllerDidChangeContent:self.doesNotMatter];
    
    [appPartialMock verify];
    [self.tableViewMock verify];
}

-(void)testThatFetchStatusIndicatorsAreSetCorrectlyOnControllerDidChangeContentDelegateCall
{
    [self expectThatDataSourceHasSomeMoreQuestionsToFetch];
    
    [self mockTableView];
    [[self.tableViewMock expect] endUpdates];
    [[self.questionsTableViewControllePartialMock expect] setFetchIndicatorsStatusTo:NO];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    [self.vc controllerDidChangeContent:self.doesNotMatter];
    
    [self.tableViewMock verify];
    [self.questionsTableViewControllePartialMock verify];
}

-(void)testThatTheFetchMoreCellIsDeletedWhenDataSourceDelegateIsCalled
{
    id appPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[appPartialMock expect] setNetworkActivityIndicatorVisible:NO];
    
    [self mockTableView];
    [self.tableViewMock setExpectationOrderMatters:YES];
    
    [[self.tableViewMock expect] beginUpdates];
    [[self.questionsTableViewControllePartialMock expect] deleteFetchMoreCell];
    [[self.tableViewMock expect] endUpdates];
    
    [self.vc fetchReturnedNoData];
    
    [appPartialMock verify];
    [self.tableViewMock verify];
    [self.questionsTableViewControllePartialMock verify];
}

- (void)testThatAppropriatePostmanMethodIsCalledWhenNewQuestionIsAdded
{
    NSString * addedQuestion = @"New Question";
    
    [[self.postmanMock expect] post:addedQuestion];

    self.vc.postman = self.postmanMock;

    [self.vc questionAdded:addedQuestion];

    [self.postmanMock verify];
}

- (void)testThatDataSourceDownloadIsForcedWhenPostmanConfirmesThatANewQuestionHasBeenAddedSuccessfully
{
    [[self.questionsDataSourceMock expect] fetchNew];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    [self.vc postDelivered];
    
    [self.questionsDataSourceMock verify];
}

@end
