//
//  EPQuestionsTableViewControllerStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 04/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMOck/OCMock.h"

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"

#import "EPQuestionDetailsTableViewController.h"
#import "EPAddQuestionViewController.h"

@interface EPQuestionsTableViewControllerStateTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewControllerState* state;

@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id viewControllerMock;

@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;

@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;

@property (nonatomic,strong) id preservationAssistantMock;
@property (nonatomic,strong) id snapshotViewMock;

@property (nonatomic,strong) id segueMock;
@property (nonatomic,strong) id questionDetailsTableViewControllerMock;
@property (nonatomic,strong) id addQuestionViewControllerMock;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerStateTests

- (id)doesNotMatter
{
    return nil;
}

- (void)expectViewIsVisible:(BOOL)isVisible
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(isVisible)] viewIsVisible];
}

- (void)expectViewNeedsRefreshing:(BOOL)needsRefreshing
{
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(needsRefreshing)] viewNeedsRefreshing];
}

- (void)expectSnapshotViewExists
{
    [[[self.preservationAssistantMock stub] andReturn:self.snapshotViewMock] snapshotView];
}

- (void)expectScrollPositionRestorationShouldBeSkipped:(BOOL)status
{
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(status)] skipTableViewScrollPositionRestoration];
}

- (void)mockFetchedResultsController
{
    [[[self.viewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
}

- (void)expectQuestionsInPersistentStorage:(BOOL)status
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(status)] hasQuestionsInPersistentStorage];
}


- (void)setUp
{
    [super setUp];
    
    self.segueMock = [OCMockObject niceMockForClass:[UIStoryboardSegue class]];
    self.questionDetailsTableViewControllerMock = [OCMockObject niceMockForClass:[EPQuestionDetailsTableViewController class]];
    self.addQuestionViewControllerMock = [OCMockObject niceMockForClass:[EPAddQuestionViewController class]];
    
    self.preservationAssistantMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStatePreservationAssistant class]];
    self.snapshotViewMock = [OCMockObject niceMockForClass:[UIImageView class]];
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    [[[self.viewControllerMock stub] andReturn:self.preservationAssistantMock] statePreservationAssistant];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.state = [[EPQuestionsTableViewControllerState alloc] initWithViewController:self.viewControllerMock
                                                                     tableViewExpert:self.tableViewExpertMock
                                                                     andStateMachine:self.stateMachineMock];
    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

//---------------------------- willResignActiveNotification ----------------------------

- (void)testThatWillResignActiveNotificationRecordsCurrentStateWhenViewIsVisibleAndThereQuestionsInPersistentStorage
{
    [self expectViewIsVisible:YES];
    [self expectQuestionsInPersistentStorage:YES];
    
    [[self.preservationAssistantMock expect] recordCurrentStateForViewController:self.viewControllerMock];
    
    [self.state willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotRecordCurrentStateWhenFetchedResultsControllerHasNoData
{
    [self expectViewIsVisible:YES];
    [self expectQuestionsInPersistentStorage:NO];
    
    [[self.preservationAssistantMock reject] recordCurrentStateForViewController:[OCMArg any]];
    
    [self.state willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatWillResignActiveNotificationDoesNotRecordCurrentStateWhenViewIsNotVisible
{
    [self expectViewIsVisible:NO];
    [self expectQuestionsInPersistentStorage:YES];
    
    [[self.preservationAssistantMock reject] recordCurrentStateForViewController:[OCMArg any]];
    
    [self.state willResignActiveNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

//---------------------------- didEnterBackgroundNotification ----------------------------

- (void)testThatDidEnterBackgroundNotificationSavesAssistantStateToPersistentStorage
{
    [[self.preservationAssistantMock expect] storeToPersistentStorage];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatDidEnterBackgroundNotificationSavesDataSourceStateToPersistentStorage
{
    [[self.questionsDataSourceMock expect] storeToPersistentStorage];
    
    [self.state didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.questionsDataSourceMock verify];
}


//---------------------------- willEnterForegroundNotification ----------------------------

- (void)testThatWillEnterForegroundNotificationRestoresFetchedResultsControllerDelegateWhenViewIsVisisbleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.viewControllerMock];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotRestoreFetchedResultsControllerDelegateWhenViewIsNotVisisble
{
    [self expectViewIsVisible:NO];
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock reject] setDelegate:self.viewControllerMock];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotRestoreFetchedResultsControllerDelegateWhenViewDoesNotNeedRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:NO];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock reject] setDelegate:self.viewControllerMock];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationPerformsFetchOnFetchedResultsControllerWhenViewIsVisibleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotChangeTheViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    [[[self.preservationAssistantMock reject] ignoringNonObjectArgs] setViewNeedsRefreshing:NO];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotChangeTheViewNeedsRefreshingFlagWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    [[[self.preservationAssistantMock reject] ignoringNonObjectArgs] setViewNeedsRefreshing:NO];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatWillEnterForegroundNotificationReloadsTableViewWhenViewIsVisibleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    
    [[self.tableViewMock expect] reloadData];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotReloadTableViewWhenViewNeedsRefreshingButViewIsNotVisible
{
    [self expectViewNeedsRefreshing:YES];
    [self expectViewIsVisible:NO];
    
    [[self.tableViewMock reject] reloadData];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotReloadTableViewWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    [self expectViewIsVisible:YES];
    
    [[self.tableViewMock reject] reloadData];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.tableViewMock verify];
}

- (void)testThatWillEnterForegroundNotificationClearsViewNeedsRefreshingFlagWhenViewIsVisibleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    [[self.preservationAssistantMock expect] setViewNeedsRefreshing:NO];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatWillEnterForegroundNotificationClearsDataSourceBackgroundFetchingModeWhenViewIsVisibleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:NO];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.questionsDataSourceMock verify];
}

//---------------------------- wiewWillDisappear ----------------------------

- (void)testThatViewWillDisappearRecordsCurrentStateWhenThereAreQuestionsInPersistentStorage
{
    [self expectQuestionsInPersistentStorage:YES];
    
    [[self.preservationAssistantMock expect] recordCurrentStateForViewController:self.viewControllerMock];
    
    [self.state viewWillDisappear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewWillDisappearDoesNotRecordCurrentStateWhenThereAreNoQuestionsInPersistentStorage
{
    [self expectQuestionsInPersistentStorage:NO];
    
    [[self.preservationAssistantMock reject] recordCurrentStateForViewController:[OCMArg any]];
    
    [self.state viewWillDisappear];
    
    [self.preservationAssistantMock verify];
}


//---------------------------- wiewWillAppear ----------------------------

- (void)testThatViewWillAppearRestoresFetchedResultsControllerDelegateWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] setDelegate:self.viewControllerMock];
    
    [self.state viewWillAppear];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatViewWillAppearDoesNotRestoreFetchedResultsControllerDelegateWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock reject] setDelegate:self.viewControllerMock];
    
    [self.state viewWillAppear];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatViewWillAppearPerformsFetchOnFetchedResultsControllerWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock expect] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.state viewWillAppear];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatViewWillAppearDoesNotPerformFetchOnFetchedResultsControllerWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    
    [self mockFetchedResultsController];
    [[self.fetchedResultsControllerMock reject] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.state viewWillAppear];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatViewWillAppearClearsViewNeedsRefreshingFlagWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    [[self.preservationAssistantMock expect] setViewNeedsRefreshing:NO];
    
    [self.state viewWillAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewWillAppearDoesNotChangeTheViewNeedsRefreshingFlagWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    [[[self.preservationAssistantMock reject] ignoringNonObjectArgs] setViewNeedsRefreshing:NO];
    
    [self.state viewWillAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewWillAppearClearsDataSourceBackgroundFetchingModeWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:NO];
    
    [self.state viewWillAppear];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatWillAppearDoesNotClearDataSourceBackgroundFetchingModeWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    [[[self.questionsDataSourceMock reject] ignoringNonObjectArgs] setBackgroundFetchMode:NO];
    
    [self.state viewWillAppear];
    
    [self.questionsDataSourceMock verify];
}


- (void)testThatViewWillAppearDisplaysSnapshotViewIfOneExists
{
    [self expectSnapshotViewExists];
    
    [[self.tableViewMock expect] addSubview:self.snapshotViewMock];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearDoesNotDisplaySnaphotViewIfRestoringTableViewScrollPositionShouldBeSkiped
{
    [self expectScrollPositionRestorationShouldBeSkipped:YES];
    [self expectSnapshotViewExists];
    
    [[self.tableViewMock reject] addSubview:self.snapshotViewMock];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearDoesNotDisplaySnapshotViewIfNoneExists
{
    [[self.tableViewMock reject] addSubview:[OCMArg any]];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearSetsTheBackgroundColorToWhiteWhenSnapshotExistsAndContentOffsetIsGreaterThanOrEqualToZero
{
    [self expectSnapshotViewExists];
    
    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    
    [[self.tableViewMock expect] setBackgroundColor:[UIColor whiteColor]];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearSetsTheBackgroundColorQuantumWhenSnapshotExistsAndContentOffsetIsLessThanZero
{
    [self expectSnapshotViewExists];
    
    CGPoint contentOffset = CGPointMake(0.0, -1.0);
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(contentOffset)] contentOffset];
    
    [[self.tableViewMock expect] setBackgroundColor:[EPQuestionsTableViewExpert colorQuantum]];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}


//---------------------------- wiewDidAppear ----------------------------

- (void)testThatViewDidAppearSetsTheBackgroundColorQuantum
{
    [[self.tableViewMock expect] setBackgroundColor:[EPQuestionsTableViewExpert colorQuantum]];
    
    [self.state viewDidAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewDidAppearRestoresIndexPathIfSnapshotExists
{
    [self expectSnapshotViewExists];
    
    [[self.preservationAssistantMock expect] restoreIndexPathOfFirstVisibleRowForViewController:self.viewControllerMock];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearDoesNotRestoresIndexPathIfTableViewScrollPositionRestorationShouldBeSkipped
{
    [self expectScrollPositionRestorationShouldBeSkipped:YES];
    [self expectSnapshotViewExists];
    
    [[self.preservationAssistantMock reject] restoreIndexPathOfFirstVisibleRowForViewController:self.viewControllerMock];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearResetsTheScrollRestorationRequiredFlag
{
    [self expectScrollPositionRestorationShouldBeSkipped:YES];
    
    [[self.preservationAssistantMock expect] setSkipTableViewScrollPositionRestoration:NO];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidSetsTheSnapshotToNilWhenScrollPositionRestorationShouldBeSkipped
{
    [self expectScrollPositionRestorationShouldBeSkipped:YES];
    
    [[self.preservationAssistantMock expect] setSnapshotView:nil];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearDoesNotRestoreIndexPathIfSnapshotDoesNotExist
{
    [[self.preservationAssistantMock reject] restoreIndexPathOfFirstVisibleRowForViewController:[OCMArg any]];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearRemovesTheSnapshotFromViewHierarchyWhenSnapshotExists
{
    [self expectSnapshotViewExists];
    
    [self.snapshotViewMock setExpectationOrderMatters:YES];
    [[self.snapshotViewMock expect] setHidden:YES];
    [[self.snapshotViewMock expect] removeFromSuperview];
    
    [self.state viewDidAppear];
    
    [self.snapshotViewMock verify];
}

- (void)testThatViewDidAppearClearsTheSnapshotViewPointerWhenSnapshotExists
{
    [self expectSnapshotViewExists];
    
    [[self.preservationAssistantMock expect] setSnapshotView:nil];

    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

//---------------------------- prepareForSegue ----------------------------

- (void)setupSegueForSegueName:(NSString*)name
{
    [[[self.segueMock stub] andReturn:name] identifier];
    
    if ([@"QuestionDetails" isEqualToString:name]) {
        [[[self.segueMock stub] andReturn:self.questionDetailsTableViewControllerMock] destinationViewController];
    } else {
        id navigationControllerMock = [OCMockObject niceMockForClass:[UINavigationController class]];
        [[[navigationControllerMock stub] andReturn:self.addQuestionViewControllerMock] topViewController];
        [[[self.segueMock stub] andReturn:navigationControllerMock] destinationViewController];
    }
    
}

- (void)setSelectedRowIndexPath:(NSIndexPath*)indexPath
{
    [[[self.tableViewMock stub] andReturn:indexPath] indexPathForSelectedRow];
}

- (void)setQuestionObject:(id)question inFetchedResultsControllerAtIndexPath:(NSIndexPath*)indexPath
{
    [self mockFetchedResultsController];
    [[[self.fetchedResultsControllerMock stub] andReturn:question] objectAtIndexPath:indexPath];
}

- (void)testThatPrepareForSequeProvidesQuestionsDetailsViewControllerWithValidQuestionObject
{
    // for all states except 'Refreshing' states we expect 1-to-1 mapping between
    // index path of selected row in table view and the index path of the
    // corresponding Question object in NSFetchedResultsViewController
    [self setupSegueForSegueName:@"QuestionDetails"];
    
    NSIndexPath* selectedRowIndexPath = [NSIndexPath indexPathForRow:10 inSection:0];
    [self setSelectedRowIndexPath:selectedRowIndexPath];
    
    id questionMock = [OCMockObject mockForClass:[Question class]];
    [self setQuestionObject:questionMock inFetchedResultsControllerAtIndexPath:selectedRowIndexPath];
    
    [[self.questionDetailsTableViewControllerMock expect] setQuestion:questionMock];
    
    [self.state prepareForSegue:self.segueMock];
    
    [self.questionDetailsTableViewControllerMock verify];
}

- (void)testThatCurrentViewControllerIsSetToBeDelegateOfTheDestinationControllerOnPerformingAddQuestionSegue
{
    [self setupSegueForSegueName:@"AddQuestion"];
    
    [[self.addQuestionViewControllerMock expect] setDelegate:self.viewControllerMock];
    
    [self.state prepareForSegue:self.segueMock];
    
    [self.addQuestionViewControllerMock verify];
}



@end
