//
//  EPFetchMoreTableViewCellTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <XCTest/XCTest.h>

#import "EPQuestionsTableViewController.h"
#import "EPFetchMoreTableViewCell.h"
#import "EPAppDelegate.h"

@interface EPFetchMoreTableViewCellTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController *questionsTableViewController;
@property (nonatomic,strong) EPFetchMoreTableViewCell *fetchMoreTableViewCell;

@end

@implementation EPFetchMoreTableViewCellTests

+ (UIStoryboard*)storyBoard
{
    static UIStoryboard *storyBoard = nil;
    
    if (nil==storyBoard) {
        storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    }
    
    return storyBoard;
}

- (void)setUp
{
    [super setUp];
    
    self.questionsTableViewController = [[EPFetchMoreTableViewCellTests storyBoard] instantiateViewControllerWithIdentifier:@"QuestionsViewController"];
    EPDependencyBox* dependencyBox = ((EPAppDelegate*)([UIApplication sharedApplication].delegate)).questionsTableViewControllerDependencyBox;
    [self.questionsTableViewController injectDependenciesFrom:dependencyBox];
    self.fetchMoreTableViewCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.questionsTableViewController.tableView
                                                                         forIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                              loading:NO];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCreatingTableViewCellByDequeueingFromTableView
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.questionsTableViewController.tableView
                                                                                     forIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                                          loading:NO];
    XCTAssertNotNil(fetchMoreCell);
    XCTAssertEqualObjects(@"FetchMore", fetchMoreCell.reuseIdentifier);
}

- (void)testThatTableViewCellHasTableViewPropertySetup
{
    XCTAssertEqualObjects(self.questionsTableViewController.tableView, self.fetchMoreTableViewCell.tableView);
}

- (void)testThatCellHasSeparatorLineHiddenAfterInitialization
{
    UIEdgeInsets expectedSeparatorInset = UIEdgeInsetsMake(0, 0, 0, self.fetchMoreTableViewCell.bounds.size.width);
    
    XCTAssertEqual(expectedSeparatorInset, self.fetchMoreTableViewCell.separatorInset);
}

@end
