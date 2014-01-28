//
//  EPQuestionsTableViewControllerDependencyBootstrapper.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import <XCTest/XCTest.h>

#import "EPQuestionsTableViewControllerDependencyBootstrapper.h"
#import "EPDependencyBox.h"
#import "EPAppDelegate.h"

@interface EPQuestionsTableViewControllerDependencyBootstrapperTests : XCTestCase

@end

@implementation EPQuestionsTableViewControllerDependencyBootstrapperTests

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

- (void)testRetrievingDependencyBoxFromBootstrapper
{
    UIApplication* app = [UIApplication sharedApplication];
    EPAppDelegate* appDelegate = (EPAppDelegate*)app.delegate;
    
    EPQuestionsTableViewControllerDependencyBootstrapper* bootstrapper = [[EPQuestionsTableViewControllerDependencyBootstrapper alloc] initWithAppDelegate:appDelegate];
    EPDependencyBox* dependencyBox = [bootstrapper bootstrap];
    
    XCTAssertNotNil(dependencyBox[@"DataSource"]);
    XCTAssertNotNil(dependencyBox[@"FetchedResultsController"]);
    XCTAssertNotNil(dependencyBox[@"StateMachine"]);
    XCTAssertNotNil(dependencyBox[@"Postman"]);
    XCTAssertNotNil(dependencyBox[@"StatePreservationAssistant"]);
}

@end
