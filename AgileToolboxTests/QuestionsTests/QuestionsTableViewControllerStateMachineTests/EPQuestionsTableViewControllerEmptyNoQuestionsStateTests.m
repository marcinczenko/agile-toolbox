//
//  EPQuestionsTableViewControllerEmptyNoQuestionsStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 21/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@interface EPQuestionsTableViewControllerEmptyNoQuestionsStateTests : XCTestCase

@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id tableViewMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerEmptyNoQuestionsState* state;

@end

@implementation EPQuestionsTableViewControllerEmptyNoQuestionsStateTests

- (void)setUp
{
    [super setUp];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.state = [[EPQuestionsTableViewControllerEmptyNoQuestionsState alloc] initWithViewController:nil
                                                                                     tableViewExpert:self.tableViewExpertMock
                                                                                     andStateMachine:nil];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatCellForRowAtIndexPathReturnsFetchMoreCellWithoutLoadingIndicator
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[fetchMoreCellClassMock expect] cellDequeuedFromTableView:self.tableViewMock forIndexPath:indexPath loading:NO];
    
    [self.state cellForRowAtIndexPath:indexPath];
    
    [fetchMoreCellClassMock verify];
}

- (void)testThatCellForRowAtIndexPathReturnsFetchMoreCellWithAdjustedText
{
    id labelMock = [OCMockObject mockForClass:[UILabel class]];
    [[labelMock expect] setText:@"No questions on the server"];
    
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[[fetchMoreCellClassMock stub] andReturn:fetchMoreCellClassMock] cellDequeuedFromTableView:[OCMArg any] forIndexPath:[OCMArg any] loading:NO];
    [[[fetchMoreCellClassMock stub] andReturn:labelMock] label];
    
    [self.state cellForRowAtIndexPath:nil];
    
    [labelMock verify];
}

- (void)testThatCellForRowAtIndexPathSetsTheTableFooter
{
    [[self.tableViewExpertMock expect] addTableFooterInOrderToHideEmptyCells];
    id fetchMoreCellClassMock = [OCMockObject niceMockForClass:[EPFetchMoreTableViewCell class]];
    [[[fetchMoreCellClassMock stub] andReturn:nil] cellDequeuedFromTableView:[OCMArg any] forIndexPath:[OCMArg any] loading:NO];
    
    [self.state cellForRowAtIndexPath:nil];
    
    [self.tableViewExpertMock verify];
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
