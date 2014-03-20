//
//  EPRefreshControlTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPTableViewRefreshControl.h"
#import "EPTableViewRefreshControlDelegate.h"

@interface EPTableViewRefreshControlTests : XCTestCase

@property (nonatomic,strong) EPTableViewRefreshControl* tableViewRefreshControl;
@property (nonatomic,strong) UIRefreshControl* testRefreshControl;
@property (nonatomic,strong) id refreshControlMock;
@property (nonatomic,strong) id tableViewControllerMock;

@property (nonatomic,strong) NSAttributedString* testAttributedTitle;

@property (nonatomic,assign) BOOL isTimeOut;

@end

@implementation EPTableViewRefreshControlTests

- (NSAttributedString*)attributedTextWithString:(NSString*)string
{
    UIFont* font = [UIFont fontWithName:@"Helvetica-Light" size:10];
    return [[NSAttributedString alloc] initWithString:string
                                           attributes: @{ NSFontAttributeName: font,
                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void) timeOut:(NSNotification*)notification
{
    self.isTimeOut = YES;
}

- (void)expectUIRefreshControlIsNil
{
    [[[self.tableViewControllerMock stub] andReturn:nil] refreshControl];
}

- (void)expectUIRefreshControlToBe:(id)refreshControl
{
    [[[self.tableViewControllerMock stub] andReturn:refreshControl] refreshControl];
}


- (void)setUp
{
    [super setUp];
    
    self.refreshControlMock = [OCMockObject niceMockForClass:[UIRefreshControl class]];
    self.tableViewControllerMock = [OCMockObject niceMockForClass:[UITableViewController class]];
    
    self.testRefreshControl = [[UIRefreshControl alloc] init];
    
    self.testAttributedTitle = [self attributedTextWithString:@"Example Title"];
    
    self.tableViewRefreshControl = [[EPTableViewRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock];
    
    self.isTimeOut = NO;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSettingAttributedTitleWhenUIRefreshControlAlreadyExists
{
    [self expectUIRefreshControlToBe:self.testRefreshControl];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    
    XCTAssertEqualObjects(self.testAttributedTitle, self.testRefreshControl.attributedTitle);
}

- (void)testThatTitlePropertyReflectsTextFromAttributedTitlePropertyAndActualRefreshControl
{
    [self expectUIRefreshControlToBe:self.testRefreshControl];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    XCTAssertEqualObjects(self.testAttributedTitle.string, self.tableViewRefreshControl.title);
    XCTAssertEqualObjects(self.tableViewRefreshControl.title, self.tableViewRefreshControl.attributedTitle.string);
    XCTAssertEqualObjects(self.testRefreshControl.attributedTitle.string, self.tableViewRefreshControl.title);
}

- (void)testSettingTitlePreservesAttributedTitleAttributes
{
    [self expectUIRefreshControlToBe:self.testRefreshControl];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    self.tableViewRefreshControl.title = @"New Title";
    
    XCTAssertEqualObjects(@"New Title", self.tableViewRefreshControl.title);
    XCTAssertEqualObjects(self.tableViewRefreshControl.title, self.tableViewRefreshControl.attributedTitle.string);
    XCTAssertEqualObjects([self.testAttributedTitle attributesAtIndex:0 effectiveRange:nil],
                          [self.tableViewRefreshControl.attributedTitle attributesAtIndex:0 effectiveRange:nil]);
    XCTAssertEqualObjects(self.testRefreshControl.attributedTitle.string, self.tableViewRefreshControl.title);
}

- (void)testThatEndRefreshingCallsEndRefreshingOnActualUIRefreshControl
{
    [self expectUIRefreshControlToBe:self.refreshControlMock];
    [[self.refreshControlMock expect] endRefreshing];
    
    [self.tableViewRefreshControl endRefreshing];
    
    [self.refreshControlMock verify];
}

- (void)testThatBeginRefreshingWithTitleSetsTheTitleAndCallsBeginRefreshing
{
    [self expectUIRefreshControlToBe:self.testRefreshControl];
    
    id refreshControlPartialMock = [OCMockObject partialMockForObject:self.tableViewRefreshControl];
    [[refreshControlPartialMock expect] beginRefreshing];
    
    [self.tableViewRefreshControl beginRefreshingWithTitle:self.testAttributedTitle.string];
    
    XCTAssertEqualObjects(self.testAttributedTitle.string, self.testRefreshControl.attributedTitle.string);
    [refreshControlPartialMock verify];
}

- (void)testThatEndRefreshingWithTitleSetsTheTiltleAndCallsEndRefreshing
{
    [self expectUIRefreshControlToBe:self.testRefreshControl];
    
    id refreshControlPartialMock = [OCMockObject partialMockForObject:self.tableViewRefreshControl];
    [[refreshControlPartialMock expect] endRefreshing];
    
    [self.tableViewRefreshControl endRefreshingWithTitle:self.testAttributedTitle.string];
    
    XCTAssertEqualObjects(self.testAttributedTitle.string, self.testRefreshControl.attributedTitle.string);
    [refreshControlPartialMock verify];
}

- (void)testCallingTheDelegate
{
    [self expectUIRefreshControlToBe:self.refreshControlMock];
    
    id refreshControlDelegate = [OCMockObject mockForProtocol:@protocol(EPTableViewRefreshControlDelegate)];
    [[refreshControlDelegate expect] refresh:self.refreshControlMock];
    
    self.tableViewRefreshControl.delegate = refreshControlDelegate;
    [self.tableViewRefreshControl refresh:self.refreshControlMock];
    
    [refreshControlDelegate verify];
}

- (void)testUsingBlockInsteadOfDelegate
{
    __block BOOL blockCalled = NO;
    
    self.tableViewRefreshControl = [[EPTableViewRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock
                                                                                     refreshBlock:^(UIRefreshControl *refreshControl) {
                                                                                         blockCalled = YES;
                                                                                     }];
    
    [self.tableViewRefreshControl refresh:self.refreshControlMock];
    
    XCTAssertTrue(blockCalled);
}



@end
