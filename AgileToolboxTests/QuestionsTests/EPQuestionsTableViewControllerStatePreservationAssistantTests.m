//
//  EPQuestionsTableViewControllerStateKeeper.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 25/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"

#import "EPQuestionsTableViewController.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistantTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewControllerStatePreservationAssistant* preservationAssistant;
@property (nonatomic,strong) id preservationAssistantPartialMock ;

@property (nonatomic,strong) id questionsTableViewControllerMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id tableViewMock;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistantTests

static const BOOL valueYES = YES;
static const BOOL valueNO = NO;

- (id)doesNotMatter
{
    return nil;
}

- (void)setUp
{
    [super setUp];
    
    self.preservationAssistant = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] init];
    self.preservationAssistantPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    
    self.questionsTableViewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)mockFetchedResultsController
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
}

- (void)mockStateMachine
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.stateMachineMock] stateMachine];
}

- (void)mockTableView
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)expectStateMachineIsLoading
{
    [[[self.stateMachineMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] isLoading];
}

- (void)expectViewNeedsRefreshing
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] viewNeedsRefreshing];
}

- (void)expectViewNeedsNoRefreshing
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(valueNO)] viewNeedsRefreshing];
}


- (void)expectViewIsVisible
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] viewIsVisibleForViewController:self.questionsTableViewControllerMock];
}

- (void)expectViewIsNotVisible
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(valueNO)] viewIsVisibleForViewController:self.questionsTableViewControllerMock];
}

- (void)makeViewNeedsRefreshingYES
{
    [self mockStateMachine];
    
    [self expectStateMachineIsLoading];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)expectStoredIndexPathToBe:(NSIndexPath*)indexPath
{
    // YES - indexForRowAtPoint: is expected to be call twice - the second call is for adjustment
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheFetchedResultsControllerDelegateToNilDuringLoadingStates
{
    [self mockFetchedResultsController];
    [self mockStateMachine];
    
    [self expectStateMachineIsLoading];
    
    [[self.fetchedResultsControllerMock expect] setDelegate:nil];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheViewNeedsRefreshingFlagToYESWhenViewControllerIsLoadingData
{
    [self mockStateMachine];
    
    [self expectStateMachineIsLoading];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testThatWillEnterForegroundNotificationRestoresTheFetchedResultsControllerDelegateWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationPerformsFetchOnTheFetchedResultsControllerWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotChangeTheViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    [self makeViewNeedsRefreshingYES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testThatWillEnterForegroundNotificationDoesNotChangeTheViewNeedsRefreshingFlagWhenViewDoesNotNeedRefreshing
{
    XCTAssertFalse(self.preservationAssistant.viewNeedsRefreshing);
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    XCTAssertFalse(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testThatDidBecomeActiveNotificationReloadsTableViewWhenViewNeedsRefreshingAndViewIsVisible
{
    [self expectViewNeedsRefreshing];
    [self expectViewIsVisible];
    
    [self mockTableView];
    [[self.tableViewMock expect] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatDidBecomeActiveNotificationDoesNotReloadTableViewWhenViewNeedsRefreshingButViewIsNotVisible
{
    [self expectViewNeedsRefreshing];
    [self expectViewIsNotVisible];
    
    [self mockTableView];
    [[self.tableViewMock reject] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];

}

- (void)testThatDidBecomeActiveNotificationDoesNotReloadTableViewWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsNoRefreshing];
    
    [self mockTableView];
    [[self.tableViewMock reject] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatDidBecomeActiveNotificationClearsViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    [self makeViewNeedsRefreshingYES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    XCTAssertFalse(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testStoringAndRestoringIndexPathOfTheFirstVisibleRow
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:10 inSection:0];
    
    [self mockTableView];
    [self expectStoredIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.preservationAssistant storeIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatIndexPathIsNotRestoredIfItWasNotStoredInTheFirstPlace
{
    [self mockTableView];
    
    [[[self.tableViewMock reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:[OCMArg any] atScrollPosition:0 animated:NO];
    
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.tableViewMock verify];
}

- (void)testThatRestoringIndexPathClearsTheRestorationHistory
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:10 inSection:0];
    
    [self mockTableView];
    [self expectStoredIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [[[self.tableViewMock reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:[OCMArg any] atScrollPosition:0 animated:NO];
    
    [self.preservationAssistant storeIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatRestoreIndexPathCallsReloadDataBeforePerformingScrolling
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:10 inSection:0];
    
    [self mockTableView];
    [self expectStoredIndexPathToBe:indexPathFirstVisibleRow];
    
    [self.tableViewMock setExpectationOrderMatters:YES];
    [[self.tableViewMock expect] reloadData];
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.preservationAssistant storeIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

@end
