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
@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id uiImageViewMock;

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
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    self.uiImageViewMock = [OCMockObject niceMockForClass:[UIImageView class]];
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
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)mockPersistentStorage
{
    [[self.preservationAssistantPartialMock expect] storeToPersistentStorage];
}

- (void)mockTableViewExpert
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
}

- (void)expectStateMachineInQuestionsLoadingState:(BOOL)value
{
    [[[self.stateMachineMock stub] andReturnValue:OCMOCK_VALUE(value)] inQuestionsLoadingState];
}

- (void)expectViewNeedsRefreshing:(BOOL)needsRefreshing
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(needsRefreshing)] viewNeedsRefreshing];
}

- (void)expectViewIsVisible:(BOOL)isVisible
{
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(isVisible)] viewIsVisibleForViewController:self.questionsTableViewControllerMock];
}

- (void)viewNeedsRefreshing:(BOOL)viewNeedsRefreshing
{
    [self mockStateMachine];
    
    [self expectStateMachineInQuestionsLoadingState:viewNeedsRefreshing];
    
    // we do not want to archive any data because we are using a mock of a table view controller in the test
    [self mockPersistentStorage];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)expectSnapshotViewExists
{
    [[[self.preservationAssistantPartialMock stub] andReturn:self.uiImageViewMock] snapshotView];
}

- (void)expectIdIsAlreadyStored
{
    id firstVisibleRowURLMock = [OCMockObject niceMockForClass:[NSURL class]];
    [[[self.preservationAssistantPartialMock stub] andReturn:firstVisibleRowURLMock] idOfTheFirstVisibleRow];
}

- (id)questionWithId:(NSNumber*)questionId
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    question.question_id = questionId;
    
    return question;
}

- (NSArray*)questionsWithQuestionIdUpToAndIncluding:(NSInteger)maxId
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray* array = [NSMutableArray new];
    
    for (int i=0; i<maxId+1; i++) {
        Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
        
        question.question_id = [NSNumber numberWithInt:i];
        
        [array addObject:question];
    }
    return array;
}

- (void)simulateFirstVisibleIndexPathToBe:(NSIndexPath*)indexPath
{
    // YES - indexForRowAtPoint: is expected to be call twice - the second call is for adjustment
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    
    NSArray* questions = [self questionsWithQuestionIdUpToAndIncluding:indexPath.row];
    
    [[[self.fetchedResultsControllerMock stub] andReturn:questions[indexPath.row]] objectAtIndexPath:indexPath];
    [[[self.fetchedResultsControllerMock stub] andReturn:questions] fetchedObjects];
}

- (void)testThatDidEnterBackgroundNotificationSetsTheFetchedResultsControllerDelegateToNilDuringLoadingStates
{
    [self mockPersistentStorage];
    
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
    [self mockPersistentStorage];
    
    [self mockStateMachine];
    
    [self expectStateMachineInQuestionsLoadingState:YES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    XCTAssertTrue(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testThatDidEnterBackgroundNotificationSavesTheStateToPersistentStorage
{
    // we should move all partial mocks into the body of the individual tests as this may be
    // the reason the tests do not finish occasionally
    id assistentPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    [[assistentPartialMock expect] storeToPersistentStorage];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                didEnterBackgroundNotification:self.doesNotMatter];
    
    [assistentPartialMock verify];
}

- (void)testThatStoreToPersistentStorageDelegatesToPersistentStoreHelper
{
    id persistentStoreHelperMock = [OCMockObject mockForClass:[EPPersistentStoreHelper class]];
    [[persistentStoreHelperMock expect] archiveObject:self.preservationAssistant
                                                    toFile:[EPQuestionsTableViewControllerStatePreservationAssistant persistentStoreFileName]];
    
    [self.preservationAssistant storeToPersistentStorage];
    
    [persistentStoreHelperMock verify];
}

- (void)testThatEncodeWithCoderSavesTheIdOfTheFirstVisibleRowToPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    id NSURLMock = [OCMockObject niceMockForClass:[NSURL class]];
    [[NSURLMock expect] encodeWithCoder:coder];
    
    [[[self.preservationAssistantPartialMock stub] andReturn:NSURLMock] idOfTheFirstVisibleRow];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [NSURLMock verify];
}

- (void)testThatEncodeWithCoderSavesTheSnapshotOfTheUIToPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    id snaphotViewMock = [OCMockObject niceMockForClass:[UIImageView class]];
    [[snaphotViewMock expect] encodeWithCoder:coder];
    
    [[[self.preservationAssistantPartialMock stub] andReturn:snaphotViewMock] snapshotView];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [snaphotViewMock verify];
}

- (void)testThatEncodeWithCoderSavesTheContentOffsetToPersistentStorage
{
    id coder = [OCMockObject mockForClass:[NSCoder class]];
    
    [[coder expect] encodeCGPoint:self.preservationAssistant.contentOffset forKey:[EPQuestionsTableViewControllerStatePreservationAssistant contentOffsetKey]];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [coder verify];
}

- (void)testThatInitWithCoderRestoresTheContentOffsetFromPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    CGPoint expectedContentOffset = CGPointMake(0.0, -64.0);
    
    [[[coder expect] andReturnValue:OCMOCK_VALUE(expectedContentOffset)] decodeCGPointForKey:[EPQuestionsTableViewControllerStatePreservationAssistant contentOffsetKey]];
    
    EPQuestionsTableViewControllerStatePreservationAssistant* assistant = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] initWithCoder:coder];
    
    XCTAssertEqual(expectedContentOffset, assistant.contentOffset);
    
    [coder verify];
}

- (void)testThatWillResignActiveNotificationCreatesASnapshotIfNoneExisitsAndViewIsVisible
{
    [self expectViewIsVisible:YES];
    
    [[self.preservationAssistantPartialMock expect] createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];

}

- (void)testThatWillResignActiveNotificationDoesNotCreateAnySnapshotsIfOneAlreadyExisits
{
    [self expectSnapshotViewExists];
    
    [[self.preservationAssistantPartialMock reject] createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotCreateAnySnapshotsIfViewIsNotVisible
{
    [self expectViewIsVisible:NO];
    
    [[self.preservationAssistantPartialMock reject] createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationStoresTheFirstVisibleRowURLIfNoneIsPresentAndViewIsVisible
{
    [self expectViewIsVisible:YES];
    
    [[self.preservationAssistantPartialMock expect] storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotStoreTheFirstVisibleRowURLIfOneIsAlreadyStored
{
    [self expectViewIsVisible:YES];
    [self expectIdIsAlreadyStored];
    
    [[self.preservationAssistantPartialMock reject] storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotStoreTheFirstVisibleRowURLIfViewIsNotVisible
{
    [self expectViewIsVisible:NO];
    
    [[self.preservationAssistantPartialMock reject] storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationStoresContentOffsetWhenViewIsVisible
{
    [self expectViewIsVisible:YES];
    
    [[self.preservationAssistantPartialMock expect] storeContentOffsetForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotStoreContentOffsetIfViewIsNotVisible
{
    [self expectViewIsVisible:NO];
    
    [[self.preservationAssistantPartialMock reject] storeContentOffsetForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatViewControllerWillDisappearCreatesTheSnapshot
{
    [[self.preservationAssistantPartialMock expect] createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewWillDisappearForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatViewControllerWillDisappearStoresTheFirstVisibleRowURL
{
    [[self.preservationAssistantPartialMock expect] storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewWillDisappearForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatViewControllerWillDisappearStoresTheContentOffset
{
    [[self.preservationAssistantPartialMock expect] storeContentOffsetForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewWillDisappearForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatCreateSnapshotForViewControllerGetsTheSnapshotFromTableViewExpertAndSavesTheResultInMemberVariable
{
    XCTAssertNil(self.preservationAssistant.snapshotView);
    
    [self mockTableViewExpert];
    
    [[[self.tableViewExpertMock expect] andReturn:self.uiImageViewMock] createSnapshotView];
    
    [self.preservationAssistant createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewExpertMock verify];
    
    XCTAssertEqualObjects(self.uiImageViewMock, self.preservationAssistant.snapshotView);
}

- (void)testThatStoreTableViewContentOffsetGetsTheContentOffsetFromTableViewExpertAndSavesTheResultInMemberVariable
{
    XCTAssertEqual(CGPointZero, self.preservationAssistant.contentOffset);
    
    CGPoint expectedContentOffset = CGPointMake(0.0, -64.0);
    
    [self mockTableViewExpert];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    [[[self.tableViewMock stub] andReturnValue:OCMOCK_VALUE(expectedContentOffset)] contentOffset];
    
    [self.preservationAssistant storeContentOffsetForViewController:self.questionsTableViewControllerMock];
    
    XCTAssertEqual(expectedContentOffset, self.preservationAssistant.contentOffset);
}

- (void)testThatWillEnterForegroundNotificationRestoresTheFetchedResultsControllerDelegateWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationPerformsFetchOnTheFetchedResultsControllerWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
               willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotChangeTheViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    // we cannot use 'expectViewNeedsRefreshing' because we need to keep viewNeedsRefreshing not mocked
    // otherwise the code wouldn't be able to modify it
    [self viewNeedsRefreshing:YES];
    
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
    [self expectViewNeedsRefreshing:YES];
    [self expectViewIsVisible:YES];
    
    [self mockTableView];
    [[self.tableViewMock expect] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatDidBecomeActiveNotificationDoesNotReloadTableViewWhenViewNeedsRefreshingButViewIsNotVisible
{
    [self expectViewNeedsRefreshing:YES];
    [self expectViewIsVisible:NO];
    
    [self mockTableView];
    [[self.tableViewMock reject] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];

}

- (void)testThatDidBecomeActiveNotificationDoesNotReloadTableViewWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    
    [self mockTableView];
    [[self.tableViewMock reject] reloadData];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatDidBecomeActiveNotificationClearsViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    [self viewNeedsRefreshing:YES];
    
    [self.preservationAssistant viewController:self.questionsTableViewControllerMock
                   didBecomeActiveNotification:self.doesNotMatter];
    
    XCTAssertFalse(self.preservationAssistant.viewNeedsRefreshing);
}

- (void)testStoringAndRestoringIndexPathOfTheFirstVisibleRow
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:10 inSection:0];
    
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

- (void)testThatViewWillAppearForViewControllerDisplaysSnapshotViewIfOneExists
{
    [self expectSnapshotViewExists];
    
    [self mockTableView];
    [[self.tableViewMock expect] addSubview:self.uiImageViewMock];
    
    [self.preservationAssistant viewWillAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
    
}

- (void)testThatViewWillAppearForViewControllerDoesNotDisplaySnapshotViewIfNoneExists
{
    [self mockTableView];
    [[self.tableViewMock reject] addSubview:[OCMArg any]];
    
    [self.preservationAssistant viewWillAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearForViewControllerSetsTheBackgroundColorToWhiteWhenSnapshotExistsAndContentOffsetIsGreaterThanOrEqualToZero
{
    [self expectSnapshotViewExists];

    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    
    [self mockTableView];
    [[self.tableViewMock expect] setBackgroundColor:[UIColor whiteColor]];
    
    [self.preservationAssistant viewWillAppearForViewController:self.questionsTableViewControllerMock];

    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearForViewControllerSetsTheBackgroundColorQuantumWhenSnapshotExistsAndContentOffsetIsLessThanZero
{
    [self expectSnapshotViewExists];
    
    CGPoint contentOffset = CGPointMake(0.0, -1.0);
    [[[self.preservationAssistantPartialMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    
    [self mockTableView];
    [[self.tableViewMock expect] setBackgroundColor:[EPQuestionsTableViewControllerStatePreservationAssistant colorQuantum]];
    
    [self.preservationAssistant viewWillAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatViewDidAppearForViewControllerSetsTheBackgroundColorQuantum
{
    [self mockTableView];
    [[self.tableViewMock expect] setBackgroundColor:[EPQuestionsTableViewControllerStatePreservationAssistant colorQuantum]];
    
    [self.preservationAssistant viewDidAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatViewDidAppearForViewControllerRestoresIndexPathIfSnapshotExists
{
    [self expectSnapshotViewExists];
    
    [[self.preservationAssistantPartialMock expect] restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant viewDidAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatViewDidAppearForViewControllerDoesNotRestoreIndexPathIfSnapshotDoesNotExist
{
    [[self.preservationAssistantPartialMock reject] restoreIndexPathOfFirstVisibleRowForViewController:[OCMArg any]];
    
    [self.preservationAssistant viewDidAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistantPartialMock verify];
}

- (void)testThatViewDidAppearRemovesTheSnapshotFromViewHierarchyWhenSnapshotExists
{
    [self expectSnapshotViewExists];
    
    [self.uiImageViewMock setExpectationOrderMatters:YES];
    [[self.uiImageViewMock expect] setHidden:YES];
    [[self.uiImageViewMock expect] removeFromSuperview];
    
    [self.preservationAssistant viewDidAppearForViewController:self.questionsTableViewControllerMock];
    
    [self.uiImageViewMock verify];
}

- (void)testThatViewDidAppearClearsTheSnapshotViewPointerWhenSnapshotExisits
{
    XCTAssertNil(self.preservationAssistant.snapshotView);
    
    [self mockTableViewExpert];
    [[[self.tableViewExpertMock stub] andReturn:self.uiImageViewMock] createSnapshotView];
    
    [self.preservationAssistant createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    XCTAssertEqualObjects(self.uiImageViewMock, self.preservationAssistant.snapshotView);
    
    [self.preservationAssistant viewDidAppearForViewController:self.questionsTableViewControllerMock];
    
    XCTAssertNil(self.preservationAssistant.snapshotView);
}




@end
