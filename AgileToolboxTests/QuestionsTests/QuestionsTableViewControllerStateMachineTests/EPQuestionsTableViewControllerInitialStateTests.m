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
@property (nonatomic,strong) id questionsRefreshControlMock;

@property (nonatomic,strong) EPQuestionsTableViewControllerInitialState* state;


@end

@implementation EPQuestionsTableViewControllerInitialStateTests

- (void)setUp
{
    [super setUp];
    
    self.applicationPartialMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    
    self.questionsRefreshControlMock = [OCMockObject niceMockForClass:[EPQuestionsRefreshControl class]];
    self.viewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    [[[self.viewControllerMock stub] andReturn:self.questionsRefreshControlMock] questionsRefreshControl];
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

- (void)expectStateChangeTo:(Class)stateClass
       whenHasQuestionsInPersistentStorage:(BOOL)hasQuestionsInPersistentStorage
  andHasMoreQuestionsToFetch:(BOOL)hasMoreQuestionsToFetch
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(hasQuestionsInPersistentStorage)] hasQuestionsInPersistentStorage];
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
         whenHasQuestionsInPersistentStorage:NO
                  andHasMoreQuestionsToFetch:YES];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadTriggersFetchWhenChangingStateToEmptyLoading
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyLoadingState class]
        whenHasQuestionsInPersistentStorage:NO
                 andHasMoreQuestionsToFetch:YES];
    
    [[self.questionsDataSourceMock expect] fetchOlderThan:nil];
    
    [self.state viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewDidLoadActivatesNetworkActivityIndicatorWhenChangingStateToEmptyLoading
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyLoadingState class]
        whenHasQuestionsInPersistentStorage:NO
                 andHasMoreQuestionsToFetch:YES];
    
    [[self.applicationPartialMock expect] setNetworkActivityIndicatorVisible:YES];
    
    [self.state viewDidLoad];
    
    [self.applicationPartialMock verify];
}


- (void)testThatViewDidLoadChangingTheStateToEmptyNoQuestions
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]
        whenHasQuestionsInPersistentStorage:NO
                 andHasMoreQuestionsToFetch:NO];
   
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadChangingTheStateToQuestionsWithFetchMore
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]
        whenHasQuestionsInPersistentStorage:YES
                 andHasMoreQuestionsToFetch:YES];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewDidLoadChangingTheStateToQuestionsNoMoreToFetch
{
    [self expectStateChangeTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]
        whenHasQuestionsInPersistentStorage:YES
                 andHasMoreQuestionsToFetch:NO];
    
    [self.state viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)expectQuestionsInPersistentStorage:(BOOL)status
{
    [[[self.viewControllerMock stub] andReturnValue:OCMOCK_VALUE(status)] hasQuestionsInPersistentStorage];
}

- (void)testThatViewDidLoadEnablesRefreshControlWhenThereAreQuestionsInPersistentStorage
{
    [self expectQuestionsInPersistentStorage:YES];

    [[self.questionsRefreshControlMock expect] enable];
    
    [self.state viewDidLoad];
    
    [self.viewControllerMock verify];
}

- (void)testThatViewDidLoadEnablesRefreshControlWhenThereAreNoQuestionsInPersistentStorage
{
    [self expectQuestionsInPersistentStorage:NO];
    
    [[self.questionsRefreshControlMock reject] enable];
    
    [self.state viewDidLoad];
    
    [self.viewControllerMock verify];
}

@end
