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
@property (nonatomic,strong) id snapshotMock;

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

- (void)expectSnapshotHasFreshImage:(BOOL)value
{
    [[[self.snapshotMock stub] andReturnValue:OCMOCK_VALUE(value)] isImageFresh];
    [[[self.preservationAssistantMock stub] andReturn:self.snapshotMock] snapshot];
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
    self.snapshotMock = [OCMockObject niceMockForClass:[EPSnapshot class]];
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

- (void)testThatWillEnterForegroundNotificationReconnectsToFetchedResultsControllerWhenViewIsVisibleAndNeedsRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:YES];
    
    [[self.viewControllerMock expect] relinkToFetchedResultsController];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.viewControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotReconnectToFetchedResultsControllerWhenViewIsVisibleButDoesNotRequireRefreshing
{
    [self expectViewIsVisible:YES];
    [self expectViewNeedsRefreshing:NO];
    
    [[self.viewControllerMock reject] relinkToFetchedResultsController];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.viewControllerMock verify];
}

- (void)testThatWillEnterForegroundNotificationDoesNotReconnectToFetchedResultsControllerWhenViewRequiresRefreshingButIsNotVisible
{
    [self expectViewIsVisible:NO];
    [self expectViewNeedsRefreshing:YES];
    
    [[self.viewControllerMock reject] relinkToFetchedResultsController];
    
    [self.state willEnterForegroundNotification:self.doesNotMatter];
    
    [self.viewControllerMock verify];
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

- (void)testThatViewWillAppearReconnectsToFetchedResultsControllerWhenViewNeedsRefreshing
{
    [self expectViewNeedsRefreshing:YES];
    
    [[self.viewControllerMock expect] relinkToFetchedResultsController];
    
    [self.state viewWillAppear];
    
    [self.viewControllerMock verify];
}

- (void)testThatViewWillAppearDoesNotReconnectToFetchedResultsControllerWhenViewDoesNotNeedRefreshing
{
    [self expectViewNeedsRefreshing:NO];
    
    [[self.viewControllerMock reject] relinkToFetchedResultsController];
    
    [self.state viewWillAppear];
    
    [self.viewControllerMock verify];
}

- (void)testThatViewWillAppearDisplaysSnapshotViewIfOneHasFreshImageAvailable
{
    [self expectSnapshotHasFreshImage:YES];
    
    [[self.snapshotMock expect] displayInView:self.tableViewMock withTag:[EPQuestionsTableViewControllerState tagSnapshot] originComputationBlock:[OCMArg any]];
    
    [self.state viewWillAppear];
    
    [self.snapshotMock verify];
}

- (void)testThatViewWillAppearDoesNotDisplaySnapshotViewIfNoneExists
{
    [[self.tableViewMock reject] addSubview:[OCMArg any]];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearSetsTheBackgroundColorToWhiteWhenSnapshotExistsAndBoundsOriginYIsGreaterThanOrEqualToZero
{
    [self expectSnapshotHasFreshImage:YES];
    
    CGRect bounds = CGRectMake(0, 0, 320, 560);
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(bounds)] bounds];
    
    [[self.tableViewMock expect] setBackgroundColor:[UIColor whiteColor]];
    
    [self.state viewWillAppear];
    
    [self.tableViewMock verify];
}

- (void)testThatViewWillAppearSetsTheBackgroundColorQuantumWhenSnapshotExistsAndBoundsOriginYIsLessThanZero
{
    [self expectSnapshotHasFreshImage:YES];
    
    CGRect bounds = CGRectMake(0, -1.0, 320, 560);
    [[[self.preservationAssistantMock stub] andReturnValue:OCMOCK_VALUE(bounds)] bounds];
    
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
    [self expectSnapshotHasFreshImage:YES];
    
    [[self.preservationAssistantMock expect] restoreIndexPathOfFirstVisibleRowForViewController:self.viewControllerMock];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearDoesNotRestoreIndexPathIfSnapshotDoesNotHaveFreshImage
{
    [self expectSnapshotHasFreshImage:NO];
    [[self.preservationAssistantMock reject] restoreIndexPathOfFirstVisibleRowForViewController:[OCMArg any]];
    
    [self.state viewDidAppear];
    
    [self.preservationAssistantMock verify];
}

- (void)testThatViewDidAppearRemovesTheSnapshotFromViewHierarchyWhenSnapshotExists
{
    [self expectSnapshotHasFreshImage:YES];
    
    [self.snapshotMock setExpectationOrderMatters:YES];
    [[self.snapshotMock expect] removeViewWithTag:[EPQuestionsTableViewControllerState tagSnapshot] fromSuperview:self.tableViewMock];
    
    [self.state viewDidAppear];
    
    [self.snapshotMock verify];
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
