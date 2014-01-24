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

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsTableViewExpert.h"
#import "EPQuestionsDataSourceProtocol.h"

#import "EPQuestionsTableViewControllerInitialState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerEmptyConnectionFailureState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsConnectionFailureState.h"

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

+ (NSMutableArray*)stateClasses
{
    static NSMutableArray* stateClassesArray = nil;
    
    if (nil == stateClassesArray) {
        stateClassesArray = [NSMutableArray arrayWithArray:@[[EPQuestionsTableViewControllerInitialState class],
                                                             [EPQuestionsTableViewControllerEmptyLoadingState class],
                                                             [EPQuestionsTableViewControllerEmptyNoQuestionsState class],
                                                             [EPQuestionsTableViewControllerEmptyConnectionFailureState class],
                                                             [EPQuestionsTableViewControllerQuestionsWithFetchMoreState class],
                                                             [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class],
                                                             [EPQuestionsTableViewControllerQuestionsLoadingState class],
                                                             [EPQuestionsTableViewControllerQuestionsConnectionFailureState class]]];
    }
    return stateClassesArray;
}

- (void)setUp
{
    [super setUp];
    self.viewControllerMock = [OCMockObject mockForClass:[EPQuestionsTableViewController class]];
    self.tableViewExpertMock = [OCMockObject mockForClass:[EPQuestionsTableViewExpert class]];
    self.questionsDataSourceMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    self.stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] init];
    [self.stateMachine assignViewController:self.viewControllerMock andTableViewExpert:self.tableViewExpertMock];
    
    self.genericStateObject = [[EPQuestionsTableViewControllerState alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCreatingStateMachine
{
    EPQuestionsTableViewControllerStateMachine *stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] init];
    XCTAssertNotNil(stateMachine);
}

- (void)testThatAfterCreatingTheCurrentStateIsSetToInitialState
{
    XCTAssertEqualObjects([EPQuestionsTableViewControllerInitialState class], [self.stateMachine.currentState class]);
}

- (void)testChangingTheState
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
    XCTAssertEqualObjects([EPQuestionsTableViewControllerEmptyLoadingState class], [self.stateMachine.currentState class]);
}

- (void)testThatStateMachineKnowsAllRequiredStates
{
    for (Class stateClass in [[self class] stateClasses]) {
        [self.stateMachine changeCurrentStateTo:stateClass];
        XCTAssertEqualObjects(stateClass, [self.stateMachine.currentState class]);
    }
}

- (void)testAssigningViewControllerAndTableViewExpertToStateMachineAndAllStates
{
    EPQuestionsTableViewControllerStateMachine *stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] init];
    
    [stateMachine assignViewController:self.viewControllerMock andTableViewExpert:self.tableViewExpertMock];
    
    XCTAssertEqualObjects(self.viewControllerMock, stateMachine.viewController);
    XCTAssertEqualObjects(self.tableViewExpertMock, stateMachine.tableViewExpert);
    
    for (Class stateClass in [self.class stateClasses]) {
        [stateMachine changeCurrentStateTo:stateClass];
        XCTAssertEqualObjects(self.viewControllerMock, stateMachine.currentState.viewController);
        XCTAssertEqualObjects(self.tableViewExpertMock, stateMachine.currentState.tableViewExpert);
        XCTAssertEqualObjects(stateMachine, stateMachine.currentState.stateMachine);
    }
}

@end
