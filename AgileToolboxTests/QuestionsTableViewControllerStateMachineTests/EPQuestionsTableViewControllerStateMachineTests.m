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

@interface EPQuestionsTableViewControllerStateMachineTests : XCTestCase

@end

@implementation EPQuestionsTableViewControllerStateMachineTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCreatingStateMachine
{
    id stateMachineDelegate = [OCMockObject mockForProtocol:@protocol(EPQuestionsTableViewControllerStateMachineDelegateProtocol)];
    EPQuestionsTableViewControllerStateMachine *stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] initWithDelegate:stateMachineDelegate];
    XCTAssertNotNil(stateMachine);
}

- (void)testSettingTheStateMachineState
{
    EPQuestionsTableViewControllerStateMachine *stateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] initWithDelegate:nil];
    id state = [OCMockObject mockForClass:[EPQuestionsTableViewControllerState class]];
    
    stateMachine.state = state;
    XCTAssertEqualObjects(state, stateMachine.state);
}

@end
