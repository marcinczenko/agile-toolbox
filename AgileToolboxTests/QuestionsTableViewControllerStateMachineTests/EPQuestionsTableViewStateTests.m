//
//  EPQuestionsTableViewState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionsTableViewControllerState.h"

@interface EPQuestionsTableViewStateTests : XCTestCase

@end

@implementation EPQuestionsTableViewStateTests

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

- (void)testThatStateHasViewControllerProperty
{
    id viewControllerMock = [OCMockObject mockForClass:[EPQuestionsTableViewController class]];
    
    EPQuestionsTableViewControllerState *state = [[EPQuestionsTableViewControllerState alloc] initWithViewController:viewControllerMock
                                                                                                     tableViewExpert:nil
                                                                                                     andStateMachine:nil];
    XCTAssertNotNil(state);
    XCTAssertEqualObjects(viewControllerMock, state.viewController);
}

- (void)testThatStateHasTableViewExpertProperty
{
    id tableViewExpertMock = [OCMockObject mockForClass:[EPQuestionsTableViewExpert class]];
    
    EPQuestionsTableViewControllerState *state = [[EPQuestionsTableViewControllerState alloc] initWithViewController:nil
                                                                                                     tableViewExpert:tableViewExpertMock
                                                                                                     andStateMachine:nil];
    XCTAssertNotNil(state);
    XCTAssertEqualObjects(tableViewExpertMock, state.tableViewExpert);
}

- (void)testThatStateHasStateMachineProperty
{
    id stateMachineMock = [OCMockObject mockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    EPQuestionsTableViewControllerState *state = [[EPQuestionsTableViewControllerState alloc] initWithViewController:nil
                                                                                                  tableViewExpert:nil
                                                                                                     andStateMachine:stateMachineMock];
    XCTAssertNotNil(state);
    XCTAssertEqualObjects(stateMachineMock, state.stateMachine);
}


@end
