//
//  EPQuestionsTableViewStateMachineTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <XCTest/XCTest.h>

#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionsTableViewControllerStateMachineDelegateProtocol.h"

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsTableViewExpert.h"
#import "EPQuestionsDataSourceProtocol.h"

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@interface EPQuestionsTableViewControllerStateMachineTests : XCTestCase

@property (nonatomic,strong) id viewControllerMock;
@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id questionsDataSourceMock;
@property (nonatomic,strong) EPQuestionsTableViewControllerStateMachine *stateMachine;

@property (nonatomic,strong) EPQuestionsTableViewControllerState *genericStateObject;

@end

@implementation EPQuestionsTableViewControllerStateMachineTests

static const BOOL valueNO = NO;
static const BOOL valueYES = YES;

- (void)setUp
{
    [super setUp];
    self.viewControllerMock = [OCMockObject mockForClass:[EPQuestionsTableViewController class]];
    self.tableViewExpertMock = [OCMockObject mockForClass:[EPQuestionsTableViewExpert class]];
    self.questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] initWithViewController:self.viewControllerMock
                                                                                andTableViewExpert:self.tableViewExpertMock];
    
    self.genericStateObject = [[EPQuestionsTableViewControllerState alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCreatingStateMachine
{
    EPQuestionsTableViewControllerStateMachine *stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc]
                                                                initWithViewController:self.viewControllerMock
                                                                andTableViewExpert:self.tableViewExpertMock];
    XCTAssertNotNil(stateMachine);
}

- (void)expectInitialStateObject:(EPQuestionsTableViewControllerState*)stateObject
                        forClass:(Class)stateClass
               noQuestionsToShow:(BOOL)noQuestionsToShow
         hasMoreQuestionsToFetch:(BOOL)hasMoreQuestionsToFetch
{
    id fetchedResultsControllerMock = [OCMockObject mockForClass:[NSFetchedResultsController class]];
    if (NO == noQuestionsToShow) {
        [[[fetchedResultsControllerMock stub] andReturn:@[@"something"]] fetchedObjects];
    } else {
        [[[fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
    }
    [[[self.viewControllerMock stub] andReturn:fetchedResultsControllerMock] fetchedResultsController];
    [[[self.questionsDataSourceMock stub] andReturnValue:OCMOCK_VALUE(hasMoreQuestionsToFetch)] hasMoreQuestionsToFetch];
    
    [[[self.viewControllerMock stub] andReturn:self.questionsDataSourceMock] questionsDataSource];
    
    [self.stateMachine setStateObject:stateObject
                         forStateName:NSStringFromClass(stateClass)];
}

- (void)testThatTheInitialStateIsCorrectlyRecognizedForEmptyLoadingState
{
    [self expectInitialStateObject:self.genericStateObject
                          forClass:[EPQuestionsTableViewControllerEmptyLoadingState class]
                 noQuestionsToShow:YES
           hasMoreQuestionsToFetch:YES];
    
    [self.stateMachine startStateMachine];
    
    XCTAssertEqualObjects(self.genericStateObject, self.stateMachine.currentState);
}

- (void)testThatTheInitialStateIsCorrectlyRecognizedForEmptyNoQuestionsState
{
    [self expectInitialStateObject:self.genericStateObject
                          forClass:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]
                 noQuestionsToShow:YES
           hasMoreQuestionsToFetch:NO];
    
    [self.stateMachine startStateMachine];
    
    XCTAssertEqualObjects(self.genericStateObject, self.stateMachine.currentState);
}

- (void)testThatTheInitialStateIsCorrectlyRecognizedForQuestionsWithFetchMoreState
{
    [self expectInitialStateObject:self.genericStateObject
                          forClass:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]
                 noQuestionsToShow:NO
           hasMoreQuestionsToFetch:YES];
    
    [self.stateMachine startStateMachine];
    
    XCTAssertEqualObjects(self.genericStateObject, self.stateMachine.currentState);
}

- (void)testThatTheInitialStateIsCorrectlyRecognizedForQuestionsNoMoreToFetchState
{
    [self expectInitialStateObject:self.genericStateObject
                          forClass:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]
                 noQuestionsToShow:NO
           hasMoreQuestionsToFetch:NO];
    
    [self.stateMachine startStateMachine];
    
    XCTAssertEqualObjects(self.genericStateObject, self.stateMachine.currentState);
}

@end
