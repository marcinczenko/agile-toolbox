//
//  EPQuestionsTableViewControllerInitialStateTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 23/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerInitialState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

#import "EPQuestionsTableViewControllerStateMachine.h"

@interface EPQuestionsTableViewControllerInitialStateTests : XCTestCase

@property (nonatomic,weak) id applicationPartialMock;

@property (nonatomic,strong) id viewControllerMock;
@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) id stateMachineMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerInitialState* state;


@end

@implementation EPQuestionsTableViewControllerInitialStateTests

- (void)setUp
{
    [super setUp];
    
    self.applicationPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    self.state = [[EPQuestionsTableViewControllerInitialState alloc] initWithViewController:self.viewControllerMock
                                                                            tableViewExpert:self.tableViewExpertMock
                                                                            andStateMachine:self.stateMachineMock];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    self.applicationPartialMock = nil;
    [super tearDown];
}

- (id) fetchedResultsControllerMockWithNoDataToFetch
{
    id fetchedResultsControllerMock = [OCMockObject mockForClass:[NSFetchedResultsController class]];
    [[[fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
    
    return fetchedResultsControllerMock;
}

- (id) fetchedResultsControllerMockWithSomeMoreDataToFetch
{
    id fetchedResultsControllerMock = [OCMockObject mockForClass:[NSFetchedResultsController class]];
    [[[fetchedResultsControllerMock stub] andReturn:@[@"something"]] fetchedObjects];
    
    return fetchedResultsControllerMock;
}

- (void)expectStateChangeTo:(Class)stateClass
       whenNoQuestionsToShow:(BOOL)noQuestionsToShow
  andHasMoreQuestionsToFetch:(BOOL)hasMoreQuestionsToFetch
{
    id fetchedResultsControllerMock = noQuestionsToShow ? [self fetchedResultsControllerMockWithNoDataToFetch] : [self fetchedResultsControllerMockWithSomeMoreDataToFetch];
    
    [[[self.viewControllerMock stub] andReturn:fetchedResultsControllerMock] fetchedResultsController];
    [[[self.questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(hasMoreQuestionsToFetch)] hasMoreQuestionsToFetch];
    
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    
    [[self.stateMachineMock expect] changeCurrentStateTo:[OCMArg checkWithBlock:^BOOL(Class actualClass) {
        XCTAssertEqualObjects(stateClass, actualClass);
        return YES;
    }]];
}

- (void)testThatViewDidLoadChangingTheStateToEmptyLoading
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyLoadingState class]
         whenNoQuestionsToShow:YES
    andHasMoreQuestionsToFetch:YES];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadTriggersFetchWhenChangingStateToEmptyLoading
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyLoadingState class]
        whenNoQuestionsToShow:YES
   andHasMoreQuestionsToFetch:YES];
    
    [[self.questionsDataSourceMock expect] fetchOlderThan:-1];
    
    [self.state viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewDidLoadActivatesNetworkActivityIndicatorWhenChangingStateToEmptyLoading
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyLoadingState class]
        whenNoQuestionsToShow:YES
   andHasMoreQuestionsToFetch:YES];
    
    [[self.applicationPartialMock expect] setNetworkActivityIndicatorVisible:YES];
    
    [self.state viewDidLoad];
    
    [self.applicationPartialMock verify];
}


- (void)testThatViewDidLoadChangingTheStateToEmptyNoQuestions
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]
        whenNoQuestionsToShow:YES
   andHasMoreQuestionsToFetch:NO];
   
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadChangingTheStateToQuestionsWithFetchMore
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]
        whenNoQuestionsToShow:NO
   andHasMoreQuestionsToFetch:YES];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadChangingTheStateToQuestionsNoMoreToFetch
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]
        whenNoQuestionsToShow:NO
   andHasMoreQuestionsToFetch:NO];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

@end
