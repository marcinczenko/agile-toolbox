//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h"
#import "EPQuestionDetailsTableViewController.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingStateTests : XCTestCase



@property (nonatomic,strong) EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState* state;

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

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingStateTests

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
    
    self.state = [[EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState alloc]
                  initWithViewController:self.viewControllerMock
                         tableViewExpert:self.tableViewExpertMock
                         andStateMachine:self.stateMachineMock];
    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

//---------------------------- prepareForSegue ----------------------------

- (void)setupSegueForSegueName:(NSString*)name
{
    [[[self.segueMock stub] andReturn:name] identifier];
    
    [[[self.segueMock stub] andReturn:self.questionDetailsTableViewControllerMock] destinationViewController];
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

- (void)testThatPrepareForSequeProvidesQuestionsDetailsViewControllerWithValidQuestionObjectWhenNativeRefreshControlIsActive
{
    [[[self.viewControllerMock stub] andReturn:[NSObject new]] refreshControl];
    
    [self setupSegueForSegueName:@"QuestionDetails"];
    
    NSIndexPath* selectedRowIndexPath = [NSIndexPath indexPathForRow:10 inSection:0];
    [self setSelectedRowIndexPath:selectedRowIndexPath];
    
    id questionMock = [OCMockObject mockForClass:[Question class]];
    [self setQuestionObject:questionMock inFetchedResultsControllerAtIndexPath:selectedRowIndexPath];
    
    [[self.questionDetailsTableViewControllerMock expect] setQuestion:questionMock];
    
    [self.state prepareForSegue:self.segueMock];
    
    [self.questionDetailsTableViewControllerMock verify];
}

- (void)testThatPrepareForSequeProvidesQuestionsDetailsViewControllerWithValidQuestionObjectWhenNativeRefreshControlIsNotActive
{
    [[[self.viewControllerMock stub] andReturn:nil] refreshControl];
    
    [self setupSegueForSegueName:@"QuestionDetails"];
    
    NSIndexPath* selectedRowIndexPath = [NSIndexPath indexPathForRow:10 inSection:0];
    [self setSelectedRowIndexPath:selectedRowIndexPath];
    
    NSIndexPath* adjustedIndexPath = [NSIndexPath indexPathForRow:selectedRowIndexPath.row-1 inSection:selectedRowIndexPath.section];
    
    id questionMock = [OCMockObject mockForClass:[Question class]];
    [self setQuestionObject:questionMock inFetchedResultsControllerAtIndexPath:adjustedIndexPath];
    
    [[self.questionDetailsTableViewControllerMock expect] setQuestion:questionMock];
    
    [self.state prepareForSegue:self.segueMock];
    
    [self.questionDetailsTableViewControllerMock verify];
}


@end
