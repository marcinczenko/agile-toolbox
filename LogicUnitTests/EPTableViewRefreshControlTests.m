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

@interface EPTestRefreshControl : EPTableViewRefreshControl

@property (nonatomic,assign) BOOL isDone;

@end

@implementation EPTestRefreshControl

- (void)beforeBeginRefreshing
{
    
}

- (void)afterBeginRefreshing
{
    [self done];
}

- (void) done
{
    self.isDone = YES;
}

@end


@interface EPTableViewRefreshControlTests : XCTestCase

@property (nonatomic,strong) EPTableViewRefreshControl* tableViewRefreshControl;
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

- (void)wait:(CGFloat) timeoutInSeconds forDelegate:(id)delegate
{
    [[NSNotificationQueue defaultQueue] enqueueNotification:
     [NSNotification notificationWithName:@"timeOut" object:self]
                                               postingStyle:NSPostWhenIdle];
    
    while (![delegate isDone] && !self.isTimeOut)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
                                                  dateWithTimeIntervalSinceNow:timeoutInSeconds]];
    }
    
}

- (void) timeOut:(NSNotification*)notification
{
    self.isTimeOut = YES;
}


- (void)setUp
{
    [super setUp];
    
    self.refreshControlMock = [OCMockObject niceMockForClass:[UIRefreshControl class]];
    self.tableViewControllerMock = [OCMockObject niceMockForClass:[UITableViewController class]];
    
    self.testAttributedTitle = [self attributedTextWithString:@"Example Title"];
    
    self.tableViewRefreshControl = [[EPTableViewRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock];
    
    self.isTimeOut = NO;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitializingWithUIRefreshControl
{
    XCTAssertNotNil(self.tableViewRefreshControl);
    XCTAssertEqualObjects([NSAttributedString new],self.tableViewRefreshControl.attributedTitle);
    XCTAssertEqualObjects([NSString new],self.tableViewRefreshControl.title);
}

- (void)testInitializingWithAttributedTitle
{
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    
    XCTAssertEqualObjects(self.testAttributedTitle, self.tableViewRefreshControl.attributedTitle);
}

- (void)testThatTextPropertyReflectsTextFromAttributedTitleProperty
{
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    XCTAssertEqualObjects(self.tableViewRefreshControl.attributedTitle.string, self.tableViewRefreshControl.title);
}

- (void)testSettingTitlePreservesAttributedTitleAttributes
{
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    self.tableViewRefreshControl.title = @"New Title";
    
    XCTAssertEqualObjects(@"New Title", self.tableViewRefreshControl.title);
    XCTAssertEqualObjects(self.tableViewRefreshControl.title, self.tableViewRefreshControl.attributedTitle.string);
    XCTAssertEqualObjects([self.testAttributedTitle attributesAtIndex:0 effectiveRange:nil],
                          [self.tableViewRefreshControl.attributedTitle attributesAtIndex:0 effectiveRange:nil]);
}

- (void)testSettingTheAttributedTitleUpdatesTheTitle
{
    NSAttributedString* attributedString = [self attributedTextWithString:@"New Attributed Title"];
    self.tableViewRefreshControl.attributedTitle = attributedString;
    
    XCTAssertEqualObjects(attributedString, self.tableViewRefreshControl.attributedTitle);
    XCTAssertEqualObjects(self.tableViewRefreshControl.title, self.tableViewRefreshControl.attributedTitle.string);
}

- (void)testThatBeginRefresingPerformesBeginRefresginSequenceWithHooks
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeOut:) name:@"timeOut" object:self];
    
    [self.refreshControlMock setExpectationOrderMatters:YES];
    [[self.refreshControlMock expect] beginRefreshing];
    [[self.refreshControlMock expect] endRefreshing];
    [[self.refreshControlMock expect] beginRefreshing];
    
    EPTestRefreshControl* refreshControl = [[EPTestRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock];
    id refreshControlPartialMock = [OCMockObject partialMockForObject:refreshControl];
    [[[refreshControlPartialMock stub] andReturn:self.refreshControlMock] uiRefreshControl];
    
    [refreshControl beginRefreshing];
    
    [self wait:1.0 forDelegate:refreshControl];
    
    XCTAssertTrue(refreshControl.isDone);
    
    [self.refreshControlMock verify];
}

- (void)testThatEndRefreshingCallsEndRefreshingOnRefreshControl
{
    [[self.refreshControlMock expect] endRefreshing];
    
    id refreshControlPartialMock = [OCMockObject partialMockForObject:self.tableViewRefreshControl];
    [[[refreshControlPartialMock stub] andReturn:self.refreshControlMock] uiRefreshControl];
    
    [self.tableViewRefreshControl endRefreshing];
    
    [self.refreshControlMock verify];
}

- (void)testThatBeginRefreshingWithTitleCallsBeginRefreshingOnUIRefreshControl
{
    [[[self.refreshControlMock stub] andReturn:self.testAttributedTitle] attributedTitle];
    
    
    id refreshControlPartialMock = [OCMockObject partialMockForObject:self.tableViewRefreshControl];
    [[[refreshControlPartialMock stub] andReturn:self.refreshControlMock] uiRefreshControl];
    [[refreshControlPartialMock expect] beginRefreshing];
    
    [self.tableViewRefreshControl beginRefreshingWithTitle:@"Some Title"];
    
    [refreshControlPartialMock verify];
}

- (void)testThatBeginRefreshingWithTitleUpdatesTheTiltle
{
    NSString* someTitle = @"SomeTitle";
    NSAttributedString* someAttributedTitle = [self attributedTextWithString:someTitle];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    [self.tableViewRefreshControl beginRefreshingWithTitle:someTitle];
    
    XCTAssertEqualObjects(someAttributedTitle, self.tableViewRefreshControl.attributedTitle);
    XCTAssertEqualObjects(someAttributedTitle, self.tableViewRefreshControl.uiRefreshControl.attributedTitle);
    
    XCTAssertEqualObjects(someTitle, self.tableViewRefreshControl.title);
}

- (void)testThatEndRefreshingWithTitleUpdatesTheTiltle
{
    NSString* someTitle = @"SomeTitle";
    NSAttributedString* someAttributedTitle = [self attributedTextWithString:someTitle];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    [self.tableViewRefreshControl endRefreshingWithTitle:someTitle];
    
    XCTAssertEqualObjects(someAttributedTitle, self.tableViewRefreshControl.attributedTitle);
    XCTAssertEqualObjects(someAttributedTitle, self.tableViewRefreshControl.uiRefreshControl.attributedTitle);
    
    XCTAssertEqualObjects(someTitle, self.tableViewRefreshControl.title);
}


- (void)testThatEndRefreshingWithTitleCallsEndRefreshingOnUIRefreshControl

{
    [[[self.refreshControlMock stub] andReturn:self.testAttributedTitle] attributedTitle];
    
    id refreshControlPartialMock = [OCMockObject partialMockForObject:self.tableViewRefreshControl];
    [[[refreshControlPartialMock stub] andReturn:self.refreshControlMock] uiRefreshControl];
    [[refreshControlPartialMock expect] endRefreshing];
    
    [self.tableViewRefreshControl endRefreshingWithTitle:@"Some Title"];
    
    [refreshControlPartialMock verify];
}

- (void)testCallingTheDelegate
{
    id refreshControlDelegate = [OCMockObject mockForProtocol:@protocol(EPTableViewRefreshControlDelegate)];
    [[refreshControlDelegate expect] refresh:self.tableViewRefreshControl];
    
    self.tableViewRefreshControl.delegate = refreshControlDelegate;
    [self.tableViewRefreshControl refresh:self.refreshControlMock];
    
    [refreshControlDelegate verify];
}

- (void)testUsingBlockInsteadOfDelegate
{
    __block BOOL blockCalled = NO;
    
    self.tableViewRefreshControl = [[EPTableViewRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock
                                                                                     refreshBlock:^(EPTableViewRefreshControl *refreshControl) {
                                                                                         blockCalled = YES;
                                                                                     }];
    
    [self.tableViewRefreshControl refresh:self.refreshControlMock];
    
    XCTAssertTrue(blockCalled);
}

- (void)testThatRefreshControlSetsAttributedTitleOnUIRefreshControl
{
    self.tableViewRefreshControl = [[EPTableViewRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock];
    
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    
    XCTAssertEqualObjects(self.testAttributedTitle, self.tableViewRefreshControl.uiRefreshControl.attributedTitle);
}

- (void)testThatRefreshControlUsesPreviousTextAttributesWhenSettingTitleWithNonAttributedString
{
    self.tableViewRefreshControl = [[EPTestRefreshControl alloc] initWithTableViewController:self.tableViewControllerMock];
    self.tableViewRefreshControl.attributedTitle = self.testAttributedTitle;
    
    NSString* title = @"New Title";
    NSAttributedString* attributedTitle = [self attributedTextWithString:title];
    
    self.tableViewRefreshControl.title = title;
    
    XCTAssertEqualObjects(attributedTitle, self.tableViewRefreshControl.uiRefreshControl.attributedTitle);
}




@end
