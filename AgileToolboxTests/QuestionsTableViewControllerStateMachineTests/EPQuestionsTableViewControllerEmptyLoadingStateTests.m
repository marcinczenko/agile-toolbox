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

#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsTableViewController.h"
#import "EPQuestionsTableViewExpert.h"
#import "EPQuestionsTableViewControllerStateMachine.h"

#import "EPFetchMoreTableViewCell.h"

@interface EPQuestionsTableViewControllerEmptyLoadingStateTests : XCTestCase

@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id viewControllerMock;

@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;

@property (nonatomic,strong) id stateMachineMock;

@property (nonatomic,weak) id applicationPartialMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerEmptyLoadingState* state;

@end

@implementation EPQuestionsTableViewControllerEmptyLoadingStateTests

const static BOOL valueNO = NO;
const static BOOL valueYES = YES;

- (void)expectThatDataSourceHasNoMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
}

- (void)expectThatDataSourceHasSomeMoreQuestionsToFetch
{
    [[[self.questionsDataSourceMock expect] andReturnValue:OCMOCK_VALUE(valueYES)] hasMoreQuestionsToFetch];
}


- (void)setUp
{
    [super setUp];
    
    self.applicationPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.viewControllerMock = [OCMockObject mockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    
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
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatViewDidLoadTriggersFetch
{
    [[self.questionsDataSourceMock expect] fetchOlderThan:-1];
    
    [self.state viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewDidLoadActivatesNetworkActivityIndicator
{
    [[self.applicationPartialMock expect] setNetworkActivityIndicatorVisible:YES];
    
    [self.state viewDidLoad];
    
    [self.applicationPartialMock verify];
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

- (void)testThatFetchReturnedNoDataRemovesTheTableFooter
{
    [[self.tableViewExpertMock expect] removeTableFooter];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewExpertMock verify];
}

- (void)testThatFetchReturnedNoDataDeletesTheFetchMoreCell
{
    [[self.tableViewExpertMock expect] deleteFetchMoreCell];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewExpertMock verify];
}

- (void)testThatFetchReturnedNoDataInsertsARowInSectionZeroAtRowIndexZero
{
    [[self.tableViewMock expect] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                       withRowAnimation:UITableViewRowAnimationNone];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewMock verify];
}

- (void)testThatFetchReturnedNoDataCallsBeginAndEndUpdatesWithOtherCallsInBetween
{
    [[self.tableViewExpertMock expect] deleteFetchMoreCell];
    [self.tableViewMock setExpectationOrderMatters:YES];
    [[self.tableViewMock expect] beginUpdates];
    [[self.tableViewMock expect] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                       withRowAnimation:UITableViewRowAnimationNone];
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.tableViewExpertMock verify];
    }] endUpdates];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewMock verify];
}

- (void)testThatFetchReturnedNoDataRemovesTableFooterBeforeUpdatingTheTable
{
    [[self.tableViewExpertMock expect] removeTableFooter];
    
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.tableViewExpertMock verify];
    }] beginUpdates];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewMock verify];
}

- (void)testThatFetchReturnedNoDataChangesTheStateBeforeCallingBeginUpdates
{
    [[self.stateMachineMock expect] changeCurrentStateTo:[OCMArg any]];
    
    [[[self.tableViewMock expect] andDo:^(NSInvocation *invocation) {
        [self.stateMachineMock verify];
    }] beginUpdates];
    
    [self.state fetchReturnedNoData];
    
    [self.tableViewMock verify];
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
