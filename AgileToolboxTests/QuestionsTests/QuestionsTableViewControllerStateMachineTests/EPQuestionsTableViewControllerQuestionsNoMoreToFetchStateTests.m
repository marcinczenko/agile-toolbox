//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchStateTests : XCTestCase

//@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id viewControllerMock;

@property (nonatomic,strong) id tableViewExpertMock;
//@property (nonatomic,strong) id tableViewMock;

@property (nonatomic,strong) id stateMachineMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerQuestionsNoMoreToFetchState* state;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchStateTests

- (id)doesNotMatter
{
    return nil;
}

- (void)stubViewControllerMostRecentQuestionId:(NSInteger)mostRecentQuestionId
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(mostRecentQuestionId)] mostRecentQuestionId];
}

- (void)stubViewControllerOldestQuestionId:(NSInteger)oldestQuestionId
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(oldestQuestionId)] oldestQuestionId];
}

- (void)setUp
{
    [super setUp];
    
//    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
//    [[[self.viewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
    
//    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
//    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.state = [[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState alloc] initWithViewController:self.viewControllerMock
                                                                                           tableViewExpert:self.tableViewExpertMock
                                                                                           andStateMachine:self.stateMachineMock];

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatRefreshCallsFetchNewAndUpdatedForQuestionIdRangeInDataSource
{
    NSInteger mostRecentQuestionId = 10;
    NSInteger oldestQuestionId = 1;
    [self stubViewControllerMostRecentQuestionId:mostRecentQuestionId];
    [self stubViewControllerOldestQuestionId:oldestQuestionId];
    [[self.questionsDataSourceMock expect] fetchNewAndUpdatedGivenMostRecentQuestionId:mostRecentQuestionId andOldestQuestionId:oldestQuestionId];
    
    [self.state refresh:self.doesNotMatter];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatRefreshChangesStateToQuestionNoMoreToFetchRefreshing
{
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState class]];
    
    [self.state refresh:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

@end
