//
//  EPQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 Marcin Czenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPQuestionsTableViewController.h"
#import "EPAddQuestionViewController.h"

#import "EPQuestionsDataSourceProtocol.h"
#import "EPPostmanProtocol.h"

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"

#import "EPQuestionsTableViewControllerState.h"
#import "Question.h"
#import "EPAppDelegate.h"


@interface EPQuestionsTableViewControllerTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController* vc;
@property (nonatomic,strong) id questionsTableViewControllePartialMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id questionsDataSourceMock;

@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;

@property (nonatomic,strong) id postmanMock;
@property (nonatomic,strong) id statePreservationAssistantMock;

@property (nonatomic,strong) id navigationControllerMock;
@property (nonatomic,strong) id addQuestionController;
@property (nonatomic,strong) id segueMock;

@property (nonatomic,strong) EPDependencyBox* dependencyBox;

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

-(void)mockTableView
{
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)mockTableViewExpert
{
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
}

- (void)setUpDependencyBox
{
    self.dependencyBox[@"DataSource"] = self.questionsDataSourceMock;
    self.dependencyBox[@"FetchedResultsController"] = self.fetchedResultsControllerMock;
    self.dependencyBox[@"StateMachine"] = self.stateMachineMock;
    self.dependencyBox[@"Postman"] = self.postmanMock;
    self.dependencyBox[@"StatePreservationAssistant"] = self.statePreservationAssistantMock;
}

- (void)setUp
{
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.postmanMock = [OCMockObject niceMockForProtocol:@protocol(EPPostmanProtocol)];
    self.statePreservationAssistantMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStatePreservationAssistant class]];
    
    self.navigationControllerMock = [OCMockObject niceMockForClass:[UINavigationController class]];
    self.addQuestionController = [OCMockObject niceMockForClass:[EPAddQuestionViewController class]];
    self.segueMock = [OCMockObject niceMockForClass:[UIStoryboardSegue class]];
    
    self.dependencyBox = [[EPDependencyBox alloc] init];
    [self setUpDependencyBox];
    self.vc = [[EPQuestionsTableViewController alloc] init];
    [self.vc injectDependenciesFrom:self.dependencyBox];
    self.questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    
}

- (void)tearDown
{
    self.questionsTableViewControllePartialMock = nil;
    [super tearDown];
}

- (void)testQuestionTableViewControllerHasPropertyForDataSourceSet
{
    XCTAssertEqualObjects(self.vc.questionsDataSource, self.questionsDataSourceMock);
}

- (void)testQuestionTableViewControllerHasPropertyForFetchedResultsControllerSet
{
    XCTAssertEqualObjects(self.vc.fetchedResultsController, self.fetchedResultsControllerMock);
}

- (void)testQuestionTableViewControllerHasPropertyForStateMachineSet
{
    XCTAssertEqualObjects(self.vc.stateMachine, self.stateMachineMock);
}

- (void)testQuestionTableViewControllerHasPropertyForPreservationAssistantSet
{
    XCTAssertEqualObjects(self.vc.statePreservationAssistant, self.statePreservationAssistantMock);
}

- (void)testThatViewDidLoadInitializesTableViewExpert
{
    [self disableViewPropertyForTheVC];
    
    [self.vc viewDidLoad];
    
    XCTAssertNotNil(self.vc.tableViewExpert);
}

- (void)testThatTableViewExpertIsAssociatedWithTheRightTableViewObject
{
    [self disableViewPropertyForTheVC];
    [self mockTableView];
    [[self.tableViewMock expect] setDelegate:self.vc];
    
    [self.vc viewDidLoad];
    
    XCTAssertNotNil(self.vc.tableViewExpert.tableView);
    XCTAssertEqualObjects(self.vc.tableView, self.vc.tableViewExpert.tableView);
}

- (void)testThatViewDidLoadAssignsViewControllerAndTableViewExpertToTheStateMachine
{
    [self disableViewPropertyForTheVC];
    
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
    
    [[self.stateMachineMock expect] assignViewController:self.vc andTableViewExpert:self.tableViewExpertMock];
    
    [self.vc viewDidLoad];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatViewDidLoadDelegatesToStateMachine
{
    [self disableViewPropertyForTheVC];

    [[self.stateMachineMock expect] viewDidLoad];
    
    [self.vc viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testQATQuestionTableViewControllerHasPropertyForPostmanService
{
    XCTAssertEqualObjects(self.vc.postman, self.postmanMock);
}

- (void)testThatViewRegistersItselfAsTheDelegateOfTheDataSource
{
    [self disableViewPropertyForTheVC];
    
    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    
    [self.vc viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfTheFetchedResultsController
{
    [self disableViewPropertyForTheVC];
    
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    [self.vc viewDidLoad];
    
    [self.fetchedResultsControllerMock verify];
}

#pragma StateMachine delegate
- (void)testThatScrollViewDidScrollDelegatesToTheStateMachine
{
    id scrollViewMock = [OCMockObject mockForClass:[UIScrollView class]];
    [[self.stateMachineMock expect] scrollViewDidScroll:scrollViewMock];
    
    [self mockTableViewExpert];
    [[[self.tableViewExpertMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollViewMock];
    
    [self.vc scrollViewWillBeginDragging:self.doesNotMatter];
    [self.vc scrollViewDidScroll:scrollViewMock];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatNumberOfSectionsInTableViewDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] numberOfSections];
    
    [self.vc numberOfSectionsInTableView:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatNumberOfRowsInSectionDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] numberOfRowsInSection:0];
    
    [self.vc tableView:self.doesNotMatter numberOfRowsInSection:0];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatCellForRowAtIndexPathDelegatesToTheStateMachine
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[self.stateMachineMock expect] cellForRowAtIndexPath:indexPath];
    
    [self.vc tableView:self.doesNotMatter cellForRowAtIndexPath:indexPath];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatFetchReturnedNoDataDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] fetchReturnedNoData];
    
    [self.vc fetchReturnedNoData];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatFetchReturnedNoDataInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] fetchReturnedNoDataInBackground];
    
    [self.vc fetchReturnedNoDataInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatControllerDidChangeContentDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] controllerDidChangeContent];
    
    [self.vc controllerDidChangeContent:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatDataChangedInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] dataChangedInBackground];
    
    [self.vc dataChangedInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatConnectionFailureInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] connectionFailureInBackground];
    
    [self.vc connectionFailureInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatConnectionFailureDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] connectionFailure];
    
    [self.vc connectionFailure];
    
    [self.stateMachineMock verify];
}

- (void)testThatWillResignActiveNotificationDelegatesToStateMachine
{
    [[self.stateMachineMock expect] willResignActiveNotification:self.doesNotMatter];
    
    [self.vc willResignActiveNotification:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

- (void)testThatDidEnterBackgroundNotificationDelegatesToStateMachine
{
    [[self.stateMachineMock expect] didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.vc didEnterBackgroundNotification:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

- (void)testThatWillEnterForegroundNotificationDelegatesToStateMachine
{
    [[self.stateMachineMock expect] willEnterForegroundNotification:self.doesNotMatter];
    
    [self.vc willEnterForegroundNotification:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

- (void)testThatDidBecomeActiveNotificationDelegatesToStateMachine
{
    [[self.stateMachineMock expect] didBecomeActiveNotification:self.doesNotMatter];
    
    [self.vc didBecomeActiveNotification:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewWillDisappearDelegatesToStateMachine
{
    [[self.stateMachineMock expect] viewWillDisappear];
    
    [self.vc viewWillDisappear:NO];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewWillAppearDelegatesToStateMachine
{
    [[self.stateMachineMock expect] viewWillAppear];
    
    [self.vc viewWillAppear:NO];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidAppearDelegatesToStateMachine
{
    [[self.stateMachineMock expect] viewDidAppear];
    
    [self.vc viewDidAppear:NO];
    
    [self.stateMachineMock verify];
}

//------------------ Refresh Controller --------------
- (void)testThatRefreshDelegatesToStateMachine
{
    [self disableViewPropertyForTheVC];
    
    [[self.stateMachineMock expect] refresh:self.doesNotMatter];
    
    [self.vc viewDidLoad];
    
    [self.vc.questionsRefreshControl refresh:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

//------------------ View Controller --------------
// Maybe will be moved to a separate type wrapping FetchedResultsController.
- (void)testRetrievingMostRecentAndOldestQuestionIdsInPersistentStorage
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Question *mostRecentQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    mostRecentQuestion.question_id = @2;
    Question *oldestQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    oldestQuestion.question_id = @1;
    
    [[[self.fetchedResultsControllerMock stub] andReturn:@[mostRecentQuestion,oldestQuestion]] fetchedObjects];
    
    XCTAssertEqual((NSInteger)2, [self.vc mostRecentQuestionId]);
    XCTAssertEqual((NSInteger)1, [self.vc oldestQuestionId]);
}

- (void)testThatRetrievingMostRecentAndOldestQuestionIdsWhenNoQuestionsInPersistentStorage
{
    [[[self.fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
    
    XCTAssertEqual((NSInteger)-1, [self.vc mostRecentQuestionId]);
    XCTAssertEqual((NSInteger)-1, [self.vc oldestQuestionId]);
}

- (void)testThatRelinkToFetchedResultsControllerRestoresFetchedResultsControllerDelegate
{
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    [self.vc relinkToFetchedResultsController];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatRelinkToFetchedResultsControllerPerformsFetchOnFetchedResultsController
{
    [[self.fetchedResultsControllerMock expect] performFetch:(NSError* __autoreleasing*)[OCMArg anyPointer]];
    
    [self.vc relinkToFetchedResultsController];
    
    [self.fetchedResultsControllerMock verify];
}

- (void)testThatRelinkToFetchedResultsControllerReloadsTableView
{
    [self mockTableView];
    [[self.tableViewMock expect] reloadData];
    
    [self.vc relinkToFetchedResultsController];
    
    [self.tableViewMock verify];
}

- (void)testThatRelinkToFetchedResultsControllerClearsViewNeedsRefreshingFlag
{
    [[self.statePreservationAssistantMock expect] setViewNeedsRefreshing:NO];
    
    [self.vc relinkToFetchedResultsController];
    
    [self.statePreservationAssistantMock verify];
}

- (void)testThatRelinkToFetchedResultsControllerClearsDataSourceBackgroundFetchingMode
{
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:NO];
    
    [self.vc relinkToFetchedResultsController];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatDisconnectFromFetchedResultsControllerSetsTheViewNeedsRefreshingFlagToYES
{
    [[self.statePreservationAssistantMock expect] setViewNeedsRefreshing:YES];

    [self.vc disconnectFromFetchedResultsController];

    [self.statePreservationAssistantMock verify];
}

- (void)testThatDisconnectFromFetchedResultsControllerSetsDataSourceBackgroundFetchingModeToYES
{
    [[self.questionsDataSourceMock expect] setBackgroundFetchMode:YES];

    [self.vc disconnectFromFetchedResultsController];

    [self.questionsDataSourceMock verify];
}

- (void)testThatDisconnectFromFetchedResultsControllerSetsTheFetchedResultsControllerDelegateToNil
{
    [[self.fetchedResultsControllerMock expect] setDelegate:nil];

    [self.vc disconnectFromFetchedResultsController];

    [self.fetchedResultsControllerMock verify];
}

//------------------ Navigating to Child View Controllers --------------
- (void)testPrepareForSegueDelegatesToStateMachine
{
    id segueMock = [OCMockObject mockForClass:[UIStoryboardSegue class]];
    [[self.stateMachineMock expect] prepareForSegue:segueMock];
    
    [self.vc prepareForSegue:segueMock sender:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

@end
