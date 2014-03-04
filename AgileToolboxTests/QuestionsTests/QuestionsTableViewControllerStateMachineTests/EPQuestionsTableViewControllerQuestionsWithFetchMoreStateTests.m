//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 21/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState.h"

#import "EPQuestionsDataSource.h"
#import "EPQuestionTableViewCell.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface EPQuestionsTableViewControllerQuestionsWithFetchMoreStateTests : XCTestCase

@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id viewControllerMock;

@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id tableViewMock;

@property (nonatomic,strong) id stateMachineMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerQuestionsWithFetchMoreState* state;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreStateTests

- (id)doesNotMatter
{
    return nil;
}

-(void)expectPersistentStorageWithNItems:(NSUInteger)numberOfRows
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] numberOfQuestionsInPersistentStorage];
}

- (void)stubViewControllerMostRecentQuestionId:(NSString*)mostRecentQuestionId
{
    [[[self.viewControllerMock stub] andReturn:mostRecentQuestionId] mostRecentQuestionId];
}

- (void)stubViewControllerOldestQuestionId:(NSString*)oldestQuestionId
{
    [[[self.viewControllerMock stub] andReturn:oldestQuestionId] oldestQuestionId];
}

- (void)stubViewControllerTimeStampOfMostRecentlyUpdatedQuestion:(NSString*)timestamp
{
    [[[self.viewControllerMock stub] andReturn:timestamp] mostRecentlyUpdatedQuestionTimestamp];
}

- (void)setUp
{
    [super setUp];
    
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.state = [[EPQuestionsTableViewControllerQuestionsWithFetchMoreState alloc] initWithViewController:self.viewControllerMock
                                                                                           tableViewExpert:self.tableViewExpertMock
                                                                                           andStateMachine:self.stateMachineMock];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatCellForRowAtIndexPathReturnsQuestionCellForSectionZero
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [[self.stateMachineMock reject] changeCurrentStateTo:[OCMArg any]];
    
    Question *question = [[Question alloc] init];
    [[[self.fetchedResultsControllerMock stub] andReturn:question] objectAtIndexPath:indexPath];
    
    id questionCellClassMock = [OCMockObject niceMockForClass:[EPQuestionTableViewCell class]];
    [[questionCellClassMock expect] cellDequeuedFromTableView:self.tableViewMock forIndexPath:indexPath andQuestion:question];
    
    [self.state cellForRowAtIndexPath:indexPath];
    
    [questionCellClassMock verify];
}

- (void)testThatCellForRowAtIndexPathReturnsFetchMoreCellWithoutLoadingIndicatorForSectionOne
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[fetchMoreCellClassMock expect] cellDequeuedFromTableView:self.tableViewMock forIndexPath:indexPath loading:NO];
    
    [self.state cellForRowAtIndexPath:indexPath];
    
    [fetchMoreCellClassMock verify];
}

- (void)testThatNumberOfRowsInSectionNumberOfRowsInFetchedResultsControllerForSectionZero
{
    NSInteger expectedNumberOfRows = 10;
    [self expectPersistentStorageWithNItems:expectedNumberOfRows];
    
    XCTAssertEqual(expectedNumberOfRows, [self.state numberOfRowsInSection:0]);
}


- (void)testThatNumberOfRowsInSectionReturnsOneForSectionOne
{
    XCTAssertEqual((NSInteger)1, [self.state numberOfRowsInSection:1]);
}

- (void)testThanNumberOfSectionsIsTwo
{
    XCTAssertEqual((NSInteger)2, [self.state numberOfSections]);
}

- (void)testThatRefreshCallsFetchNewAndUpdatedForQuestionIdRangeInDataSource
{
    NSString* timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    [self stubViewControllerTimeStampOfMostRecentlyUpdatedQuestion:timestamp];
    [[self.questionsDataSourceMock expect] fetchNewAndUpdatedAfterTimestamp:timestamp];
    
    [self.state refresh:self.doesNotMatter];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatRefreshChangesStateToQuestionsWithFetchMoreRefreshing
{
    [[self.stateMachineMock expect] changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState class]];
    
    [self.state refresh:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}


@end
