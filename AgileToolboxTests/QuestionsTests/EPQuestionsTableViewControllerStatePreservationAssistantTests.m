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
#import "EPPersistentStoreHelper.h"
#import "EPAppDelegate.h"
#import "Question.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistantTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewControllerStatePreservationAssistant* preservationAssistant;
@property (nonatomic,strong) id preservationAssistantPartialMock ;

@property (nonatomic,strong) id questionsTableViewControllerMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id persistentStoreHelperMock;

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
    
    self.persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
}

- (void)tearDown
{
    self.preservationAssistantPartialMock = nil;
    
    [super tearDown];
}

- (void)mockFetchedResultsController
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
}

- (void)simulateFetchedResultsControllerHasNoData
{
   [[[self.fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
}

- (void)mockStateMachine
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.stateMachineMock] stateMachine];
}

- (void)mockTableView
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)expectStateMachineInQuestionsLoadingState:(BOOL)value
{
    [[[self.stateMachineMock stub] andReturnValue:OCMOCK_VALUE(value)] inQuestionsLoadingState];
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
    
    [self expectStateMachineInQuestionsLoadingState:YES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (id)questionWithId:(NSNumber*)questionId
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    question.question_id = questionId;
    
    return question;
}

- (void)simulateFirstVisibleIndexPathToBe:(NSIndexPath*)indexPath
{
    // YES - indexForRowAtPoint: is expected to be call twice - the second call is for adjustment
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    
    id question = [self questionWithId:[NSNumber numberWithInteger:indexPath.row]];
    [[[self.fetchedResultsControllerMock stub] andReturn:question] objectAtIndexPath:indexPath];
    [[[self.fetchedResultsControllerMock stub] andReturn:@[question]] fetchedObjects];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheFetchedResultsControllerDelegateToNilDuringLoadingStates
{
    [self mockFetchedResultsController];
    [self mockStateMachine];
    
    [self expectStateMachineInQuestionsLoadingState:YES];
    
    [[self.fetchedResultsControllerMock expect] setDelegate:nil];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheViewNeedsRefreshingFlagToYESWhenViewControllerIsLoadingData
{
    [self mockStateMachine];
    
    [self expectStateMachineInQuestionsLoadingState:YES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testThatDidEnterBackgroundNotificationStoresTheIdOfTheFirstVisibleQuestionToPersistentStorage
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.persistentStoreHelperMock expect] storeDictionary:@{@"FirstVisibleQuestionId":[NSNumber numberWithInteger:indexPathFirstVisibleRow.row]}
                                                      toFile:[EPQuestionsTableViewControllerStatePreservationAssistant persistentStoreFileName]];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.persistentStoreHelperMock verify];
}

- (void)testThatDidEnterBackgroundNotificationDoesNotStoreAnythingWhenThereAreNoQuestionsInFetchedResultsController
{
    [self mockFetchedResultsController];
    [self simulateFetchedResultsControllerHasNoData];
    
    [[self.persistentStoreHelperMock reject] storeDictionary:[OCMArg any]
                                                      toFile:[OCMArg any]];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.persistentStoreHelperMock verify];
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
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.preservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
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
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [[[self.tableViewMock reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:[OCMArg any] atScrollPosition:0 animated:NO];
    
    [self.preservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatRestoreIndexPathCallsReloadDataBeforePerformingScrolling
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [self.tableViewMock setExpectationOrderMatters:YES];
    [[self.tableViewMock expect] reloadData];
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.preservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

@end
