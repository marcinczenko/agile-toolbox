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

- (void)testCreatingAState
{
//    id stateMachine = [OCMockObject mockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    
    EPQuestionsTableViewControllerState *state = [EPQuestionsTableViewControllerState instance];
    XCTAssertNotNil(state);
}

@end
