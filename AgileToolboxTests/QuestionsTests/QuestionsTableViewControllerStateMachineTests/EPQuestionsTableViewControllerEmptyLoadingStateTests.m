//
//  EPQuestionsTableViewControllerEmptyLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@interface EPQuestionsTableViewControllerEmptyLoadingStateTests : XCTestCase

@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id viewControllerMock;

@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;

@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;

@property (nonatomic,weak) id applicationPartialMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerEmptyLoadingState* state;

@property (nonatomic,strong) id preservationAssistantMock;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerEmptyLoadingStateTests

const static BOOL valueNO = NO;
const static BOOL valueYES = YES;

- (id)doesNotMatter
{
    return nil;
}

- (void)expectThatDataSourceHasNoMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
}

- (void)expectThatDataSourceHasSomeMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueYES)] hasMoreQuestionsToFetch];
}

- (void)expectQuestionsInPersistentStorage:(BOOL)state
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(state)] hasQuestionsInPersistentStorage];
}

- (void)mockFetchedResultsController
{
    [[[self.viewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
}


- (void)setUp
{
    [super setUp];
    
    self.applicationPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    
    self.preservationAssistantMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStatePreservationAssistant class]];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    [[[self.viewControllerMock stub] andReturn:self.preservationAssistantMock] statePreservationAssistant];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.state = [[EPQuestionsTableViewControllerEmptyLoadingState alloc] initWithViewController:self.viewControllerMock
                                                                                        tableViewExpert:self.tableViewExpertMock
                                                                                        andStateMachine:self.stateMachineMock];
}

- (void)tearDown
{
    self.applicationPartialMock = nil;
    
    
    [super tearDown];
}

- (void)testThatViewWillDisappearSetsFetchedResultsControllerDelegateToNil
{
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:nil];
    
    [self.state viewWillDisappear];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatViewWillDisappearSetsTheViewNeedsRefreshingFlagToYES
{
    [[self.preservationAssistantMock expect] setViewNeedsRefreshing:YES];
    
    [self.state viewWillDisappear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewWillDisappearSetsDataSourceBackgroundFetchingModeToYES
{
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:YES];
    
    [self.state viewWillDisappear];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewWillDisappearRecordsTheCurrentStateWhenThereAreQuestionsInPersistentStorage
{
    [self expectQuestionsInPersistentStorage:YES];
    
    [[self.preservationAssistantMock expect] recordCurrentStateForViewController:self.viewControllerMock];
    
    [self.state viewWillDisappear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheFetchedResultsControllerDelegateToNil
{
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:nil];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheViewNeedsRefreshingFlagToYES
{
    [[self.preservationAssistantMock expect] setViewNeedsRefreshing:YES];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSetsDataSourceBackgroundFetchingModeToYES
{
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:YES];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.questionsDataSourceMock verify];
}


- (void)testThatDidEnterBackgroundNotificationSavesTheStateToPersistentStorage
{
    [[self.preservationAssistantMock expect] storeToPersistentStorage];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatControllerDidChangeContentsChangesTheStateToQuestionsWithFetchMoreStateWhenDataSourceHasMoreQuestionsToFetch
{
    [self expectThatDataSourceHasSomeMoreQuestionsToFetch];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    
    [self.state controllerDidChangeContent];
    
    [self.stateMachineMock verify];
}

- (void)testThatControllerDidChangeContentsChangesTheStateToQuestionsNoMoreToFetchStateWhenDataSourceDoesNotHaveAnyMoreQuestionsToFetch
{
    [self expectThatDataSourceHasNoMoreQuestionsToFetch];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    [self.state controllerDidChangeContent];
    
    [self.stateMachineMock verify];
}

- (void)testThatControllerDidChangeContentsDeactivatesNetworkActivityIndicator
{
    [[self.applicationPartialMock expect] setNetworkActivityIndicatorVisible:NO];
    
    [self.state controllerDidChangeContent];
    
    [self.applicationPartialMock verify];
}

- (void)testThatEndUpdatesIsCalledAFTERTheStateIsChangedWhenDataSourceHasMoreQuestionsToFetch
{
    [self expectThatDataSourceHasSomeMoreQuestionsToFetch];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.stateMachineMock verify];
    }] endUpdates];
    
    [self.state controllerDidChangeContent];
    
    [self.tableViewMock verify];
}

- (void)testThatEndUpdatesIsCalledAFTERTheStateIsChangedWhenDataSourceDoesNotHaveAnyMoreQuestionsToFetch
{
    [self expectThatDataSourceHasNoMoreQuestionsToFetch];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.stateMachineMock verify];
    }] endUpdates];
    
    [self.state controllerDidChangeContent];
    
    [self.tableViewMock verify];
}

- (void)testThatTheFetchMoreCellIsDeletedAFTERTheStateIsChangedAndBEFORETheEndUpdatesIsInvokedWhenDataSourceDoesNotHaveAnyMoreQuestionsToFetch
{
    [self expectThatDataSourceHasNoMoreQuestionsToFetch];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    [[[self.tableViewExpertMock expect] andDo:^(NSInvocation *invocation) {
        [self.stateMachineMock verify];
    }] deleteFetchMoreCell];
    
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.tableViewExpertMock verify];
    }] endUpdates];
    
    [self.state controllerDidChangeContent];
    
    [self.tableViewMock verify];
}

- (void)testThatCellForRowAtIndexPathReturnsFetchMoreCellIndicatingThatLoadingIsInProgress
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[fetchMoreCellClassMock expect] cellDequeuedFromTableView:self.tableViewMock forIndexPath:indexPath loading:YES];
    
    [self.state cellForRowAtIndexPath:indexPath];
    
    [fetchMoreCellClassMock verify];
}

- (void)testThatCellForRowAtIndexPathAddsTableFooter
{
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[fetchMoreCellClassMock stub] cellDequeuedFromTableView:[OCMArg any] forIndexPath:[OCMArg any] loading:YES];
    
    [[self.tableViewExpertMock expect] addTableFooterInOrderToHideEmptyCells];
    
    [self.state cellForRowAtIndexPath:nil];
    
    [self.tableViewExpertMock verify];
}

- (void)testThatFetchReturnedNoDataChangesStateToEmptyNoQuestionsState
{
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    
    [self.state fetchReturnedNoData];
    
    [self.stateMachineMock verify];
}

- (void)testThatFetchReturnedNoDataDeactivatesTheNetworkActivityIndicator
{
    [[self.applicationPartialMock expect] setNetworkActivityIndicatorVisible:NO];
    
    [self.state fetchReturnedNoData];
    
    [self.applicationPartialMock verify];
}

- (void)testThatNumberOfRowsInSectionReturnZeroForSectionZero
{
    XCTAssertEqual((NSInteger)0, [self.state numberOfRowsInSection:0]);
}

- (void)testThatNumberOfRowsInSectionReturnOneForSectionOne
{
    XCTAssertEqual((NSInteger)1, [self.state numberOfRowsInSection:1]);
}

- (void)testThanNumberOfSectionsIsTwo
{
    XCTAssertEqual((NSInteger)2, [self.state numberOfSections]);
}


@end
