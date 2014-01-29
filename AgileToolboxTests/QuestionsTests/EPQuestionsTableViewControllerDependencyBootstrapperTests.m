//
//  EPQuestionsTableViewControllerDependencyBootstrapper.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerDependencyBootstrapper.h"
#import "EPDependencyBox.h"
#import "EPAppDelegate.h"
#import "EPPersistentStoreHelper.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"

@interface EPQuestionsTableViewControllerDependencyBootstrapperTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewControllerDependencyBootstrapper* bootstrapper;
@property (nonatomic,strong) EPDependencyBox* dependencyBox;

@property (nonatomic,strong) id persistentStoreHelperMock;
@property (nonatomic,weak) EPAppDelegate* appDelegate;

@end

@implementation EPQuestionsTableViewControllerDependencyBootstrapperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    // YEAH - the text above is divine !
    
    self.persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    
    self.bootstrapper = [[EPQuestionsTableViewControllerDependencyBootstrapper alloc] initWithAppDelegate:[[UIApplication sharedApplication] delegate]];
}

- (void)tearDown
{
    self.persistentStoreHelperMock = nil;
    
    [super tearDown];
}

- (void)testRetrievingDependencyBoxFromBootstrapper
{
    self.dependencyBox = [self.bootstrapper bootstrap];
    
    XCTAssertNotNil(self.dependencyBox[@"DataSource"]);
    XCTAssertNotNil(self.dependencyBox[@"FetchedResultsController"]);
    XCTAssertNotNil(self.dependencyBox[@"StateMachine"]);
    XCTAssertNotNil(self.dependencyBox[@"Postman"]);
    XCTAssertNotNil(self.dependencyBox[@"StatePreservationAssistant"]);
}

- (void)simulatePersistentStateForQuestionsDataSource
{
    [[[self.persistentStoreHelperMock stub] andReturn:@{@"HasMoreQuestionsToFetch":@NO}] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    [[[self.persistentStoreHelperMock stub] andReturn:nil] readDictionaryFromFile:[OCMArg any]];
}

- (void)simulatePersistentStateForPreservationAssistant
{
    [[[self.persistentStoreHelperMock stub] andReturn:@{@"FirstVisibleQuestionId":@42}] readDictionaryFromFile:[EPQuestionsTableViewControllerStatePreservationAssistant persistentStoreFileName]];
    [[[self.persistentStoreHelperMock stub] andReturn:nil] readDictionaryFromFile:[OCMArg any]];
}


- (void)testThatDataSourceIsRestoredFromPersistentStorage
{
    [self simulatePersistentStateForQuestionsDataSource];
    
    self.dependencyBox = [self.bootstrapper bootstrap];
    
    id<EPQuestionsDataSourceProtocol> questionsDataSource = self.dependencyBox[@"DataSource"];
    
    XCTAssertFalse(questionsDataSource.hasMoreQuestionsToFetch);
}

- (void)testThatStatePreservationAssistantIsRestoredFromPersistentStorage
{
    [self simulatePersistentStateForPreservationAssistant];
    
    self.dependencyBox = [self.bootstrapper bootstrap];
    
    EPQuestionsTableViewControllerStatePreservationAssistant* statePreservationAssistant = self.dependencyBox[@"StatePreservationAssistant"];
    
    XCTAssertEqualObjects(@42, statePreservationAssistant.idOfTheFirstVisibleRow);
}


@end
