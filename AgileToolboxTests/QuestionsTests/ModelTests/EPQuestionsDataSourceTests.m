//
//  EPQuestionsDataSourceTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/7/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <CoreData/CoreData.h>
#import "EPAppDelegate.h"
#import "Question.h"

#import "EPQuestionsDataSource.h"
#import "EPConnectionDelegateProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPPersistentStoreHelper.h"

@interface EPQuestionsDataSourceTests : XCTestCase

@property (nonatomic,readonly) id doesNotMatter;
@property (nonatomic,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,readonly) NSManagedObjectContext *backgroundContext;
@property (nonatomic,readonly) EPAppDelegate* appDelegate;

@property (nonatomic,strong) EPQuestionsDataSource *questionsWithConnectionMock;
@property (nonatomic,strong) EPQuestionsDataSource *questionsWithNilConnection;
@property (nonatomic,strong) id dataSourceDelegateMock;

@property (nonatomic,strong) id connectionMock;

- (NSData*) createJsonDataFromJsonDictionary:(id) json_object;
- (NSArray*) generateJsonArrayWithTestQuestionsWithNElements:(NSInteger)numberOfElements includingAnswers:(BOOL)includeAnswers;


@end

@implementation EPQuestionsDataSourceTests

static const BOOL valueNO = NO;
static const BOOL valueYES = YES;

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"http://example.com"];
}

- (id) doesNotMatter
{
    return nil;
}

- (NSNumber*)generateExampleDateAsNSNumberShiftedBy:(int)seconds
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"dd MM yyyy HH:mm:ss.SSSSSS ZZZZ"];
    NSDate *date = [df dateFromString:@"11 01 2014 13:05:00.945000 GMT"];
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]+(seconds/60.0)];
}

- (NSDictionary*)createQuestionJsonObjectWithDate:(NSNumber*)date andSequence:(int)sequence includingAnswer:(BOOL)includeAnswer
{
    id answer = includeAnswer ? [NSString stringWithFormat:@"Answer for item%ld",(long)sequence] : [NSNull null];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"header for item%ld",(long)sequence],@"header",
            [NSString stringWithFormat:@"item%ld",(long)sequence],@"content",
            date,@"updated",
            date,@"created",
            answer, @"answer",
            [NSNumber numberWithInt:sequence], @"id",
            nil];
}

- (NSArray*) generateJsonArrayWithTestQuestionsWithNElements:(NSInteger)numberOfElements includingAnswers:(BOOL)includeAnswers
{
    NSMutableArray* jsonArray = [NSMutableArray arrayWithCapacity:numberOfElements];
    
    for (int index=(int)numberOfElements; index>0; index--) {
        [jsonArray addObject:[self createQuestionJsonObjectWithDate:[self generateExampleDateAsNSNumberShiftedBy:index]
                                                          andSequence:index
                                                      includingAnswer:includeAnswers]];
    }

    return jsonArray;
}

- (NSData*) createJsonDataFromJsonDictionary:(id) jsonDictionary
{
    return [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:NULL];;
}

- (NSArray*)updateContentInJsonArray:(NSArray*)array
{
    NSMutableArray* updatedArray = [NSMutableArray new];
    for (NSDictionary* dict in array) {
        NSMutableDictionary* updatedDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
        updatedDictionary[@"content"] = [NSString stringWithFormat:@"%@-UPDATED", dict[@"content"]];
        updatedDictionary[@"answer"] = @"Answer";
        [updatedArray addObject:updatedDictionary];
    }
    
    NSLog(@"%@",updatedArray);
    
    return updatedArray;
}

- (void)compareCoreDataWithJsonArray:(NSArray*)array
{
    int index = 0;
    NSArray* questionsFromCoreData = [self getQuestionsFromDataStoreDescending];
    XCTAssertNotNil(questionsFromCoreData);
    XCTAssertNotEqual((NSUInteger)0, questionsFromCoreData.count);
    for (Question *question in questionsFromCoreData) {
        XCTAssertEqualObjects(question.header, [array[index] objectForKey:@"header"]);
        XCTAssertEqualObjects(question.content, [array[index] objectForKey:@"content"]);
        if ([NSNull null] == [array[index] objectForKey:@"answer"]) {
            XCTAssertNil(question.answer);
        } else {
            XCTAssertEqualObjects(question.answer, [array[index] objectForKey:@"answer"]);
        }
        XCTAssertEqualWithAccuracy(question.created.timeIntervalSince1970, [(NSNumber*)([array[index] objectForKey:@"created"]) doubleValue], 0.001);
        XCTAssertEqualWithAccuracy(question.updated.timeIntervalSince1970, [(NSNumber*)([array[index] objectForKey:@"updated"]) doubleValue], 0.001);
        index++;
    }
}


- (EPAppDelegate*) appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    return self.appDelegate.persistentStoreCoordinator;
}

- (NSManagedObjectContext*) managedObjectContext
{
    return self.appDelegate.managedObjectContext;
}

- (NSArray*)getQuestionsFromDataStoreDescending
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    fetchRequest.sortDescriptors = @[createdSort];
    
    NSError *requestError = nil;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
}

- (void)simulateBackgroundModeFor:(id)questionsPartialMock
{
    [[[questionsPartialMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] backgroundFetchMode];
}

-(void)mockOutCallingCoreDataFor:(id)questionsPartialMock
{
    [[questionsPartialMock stub] addToCoreData:[OCMArg any]];
}


-(EPQuestionsDataSource*)createQuestionsDataSourceWithConnection:(id)connection
{
    return [[EPQuestionsDataSource alloc] initWithConnection:connection
                           andWithManagedObjectContext:self.managedObjectContext];
}

-(EPQuestionsDataSource*)setupQuestionsWithConnectionMock:(id)connectionMock
{
    [[connectionMock expect] setDelegate:[OCMArg any]];
    return [self createQuestionsDataSourceWithConnection:connectionMock];
}

-(EPQuestionsDataSource*)setupQuestionsWithNilConnection
{
    return [self createQuestionsDataSourceWithConnection:nil];
}

-(void)setUp
{
    [self.appDelegate clearPersistentStore];
    
    self.connectionMock = [OCMockObject niceMockForProtocol:@protocol(EPConnectionProtocol)];
    
    self.questionsWithConnectionMock = [self setupQuestionsWithConnectionMock:self.connectionMock];
    self.questionsWithNilConnection = [self setupQuestionsWithNilConnection];
    
    self.dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
}

-(void)tearDown
{
}

-(void)testFetching1stSetOfQuestions
{
    [[self.connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    
    [self.questionsWithConnectionMock fetchOlderThan:-1];
    
    [self.connectionMock verify];
}

-(void)testFetchingQuestionsAddedBeforeElementWithGivenId
{
    int anID = 123;
    [self.connectionMock setExpectationOrderMatters:YES];
    [[self.connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                              @"before": [NSString stringWithFormat:@"%d",anID]}];
    
    [self.questionsWithConnectionMock fetchOlderThan:anID];
    
    [self.connectionMock verify];
}

- (void)testFetchingNewAndUpdatedQuestions
{
    int mostRecentQuestionId = 10;
    int oldestQuestionId = 1;
    [self.connectionMock setExpectationOrderMatters:YES];
    [[self.connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                              @"newest": [NSString stringWithFormat:@"%d",mostRecentQuestionId],
                                                              @"oldest": [NSString stringWithFormat:@"%d",oldestQuestionId]}];
    
    [self.questionsWithConnectionMock fetchNewAndUpdatedGivenMostRecentQuestionId:mostRecentQuestionId andOldestQuestionId:oldestQuestionId];
    
    [self.connectionMock verify];
}

- (void)testThatQuestionsMarkedAsOldAreProperlySavedToCoreDataOnReception
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];

    [self compareCoreDataWithJsonArray:jsonArray];
}

- (void)testThatQuestionsMarkedAsNewAreProperlySavedToCoreDataOnReception
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":jsonArray,
                                                                                                @"updated":@[]}]];
    
    [self compareCoreDataWithJsonArray:jsonArray];
}

- (void)testThatQuestionsMarkedAsUpdatedAreProperlySavedToCoreDataOnReception
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];
    
    NSArray* updatedJsonArray = [self updateContentInJsonArray:jsonArray];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":updatedJsonArray}]];
    
    [self compareCoreDataWithJsonArray:updatedJsonArray];
}

- (void)testThatIfThereAreNoQuestionsMarkedAsOldTheHasMoreQuestionsToFetchRemainsUnchanged
{
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":@[]}]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDownloadCompletedCallsFetchedReturnedNoDataWhenBothNewAndUpdatedAreEmpty
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoData];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDownloadCompletedDoesNotCallFetchedReturnedNoDataWhenNewIsNotEmpty
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [[self.dataSourceDelegateMock reject] fetchReturnedNoData];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":jsonArray,
                                                                                                @"updated":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDownloadCompletedDoesNotCallFetchedReturnedNoDataWhenUpdatedIsNotEmpty
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [[self.dataSourceDelegateMock reject] fetchReturnedNoData];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":jsonArray}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDownloadCompletedCallsFetchedReturnedNoDataInBackgroundWhenBothNewAndUpdatedAreEmptyAndDataSourceIsInBackgroundFetchMode
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoDataInBackground];
    
    self.questionsWithNilConnection.backgroundFetchMode = YES;
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDownloadCompletedCallsDataChangedInBackgroundWhenNewIsNotEmpty
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [[self.dataSourceDelegateMock expect] dataChangedInBackground];
    
    self.questionsWithNilConnection.backgroundFetchMode = YES;
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":jsonArray,
                                                                                                @"updated":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDownloadCompletedCallsDataFetchedInBackgroundWhenUpdatedIsNotEmpty
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [[self.dataSourceDelegateMock expect] dataChangedInBackground];
    
    self.questionsWithNilConnection.backgroundFetchMode = YES;
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"new":@[],
                                                                                                @"updated":jsonArray}]];
    
    [self.dataSourceDelegateMock verify];
}


- (void)testThatTheDelegateOfTheConnectionObjectIsSet
{
    __block EPQuestionsDataSource *delegate;
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    
    [[connectionMock expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock
                                                       andWithManagedObjectContext:self.managedObjectContext];
    
    [connectionMock verify];
    
    XCTAssertEqualObjects(questions, delegate, @"Wrong delegate passed to connection object.");
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedLessThanOnePageOfQuestions
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:EPQuestionsDataSource.pageSize-1 includingAnswers:NO];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];
    
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedExactlyOneQuestion
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:1 includingAnswers:NO];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];
    
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToYESWhenLastFetchReturnedExactlyOnePageOfQuestions
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:EPQuestionsDataSource.pageSize includingAnswers:NO];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceCallsFetchReturnedNoDataDelegateWhenNoDataHasBeenFetchedFromTheServer
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoData];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceCallsFetchReturnedNoDataInBackgroundDelegateWhenNoDataHasBeenFetchedFromTheServerAndSystemIsInBackgroundMode
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoDataInBackground];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self simulateBackgroundModeFor:questionsPartialMock];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":@[]}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceCallsDataChangedInBackgroundWhenDataReceivedInBackground
{
    NSArray* jsonArray = [self generateJsonArrayWithTestQuestionsWithNElements:5 includingAnswers:NO];
    
    [[self.dataSourceDelegateMock expect] dataChangedInBackground];
    
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [self mockOutCallingCoreDataFor:questionsPartialMock];
    [self simulateBackgroundModeFor:questionsPartialMock];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":jsonArray}]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceDoesNotSaveDataToCoreDataWhenServerReturnsNoAnswers
{
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [[questionsPartialMock reject] addToCoreData:[OCMArg any]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":@[]}]];
}

- (void)testThatStoreToPersistentStorageStoresHasMoreQuestionsToFetchStatus
{
    id questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [[[questionsPartialMock stub] andReturnValue:OCMOCK_VALUE(valueNO)] hasMoreQuestionsToFetch];
    
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[persistentStoreHelperMock expect] storeDictionary:@{[EPQuestionsDataSource hasMoreQuestionsToFetchKey]:[NSNumber numberWithBool:valueNO]}
                                                 toFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection storeToPersistentStorage];
    
    [persistentStoreHelperMock verify];
}

- (void)testThatDataSourceRestoresPreviouslyStoredContentWhenHasMoreQuestionsToFetchIsYES
{
    NSDictionary* restoredDictionary = @{[EPQuestionsDataSource hasMoreQuestionsToFetchKey]:[NSNumber numberWithBool:YES]};
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceRestoresPreviouslyStoredContentWhenHasMoreQuestionsToFetchIsNO
{
    NSDictionary* restoredDictionary = @{[EPQuestionsDataSource hasMoreQuestionsToFetchKey]:[NSNumber numberWithBool:NO]};
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenDataDoesNoExist_ForNO
{
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: nil] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":@[]}]];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenDataDoesNoExist_ForYES
{
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: nil] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenKeyForHasMoreDataToFetchDoesNotExist_ForNO
{
    NSDictionary* restoredDictionary = @{@"DummyKey":@123};
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJsonDataFromJsonDictionary:@{@"old":@[]}]];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenKeyForHasMoreDataToFetchDoesNotExist_ForYES
{
    NSDictionary* restoredDictionary = @{@"DummyKey":@123};
    id persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
    [[[persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

@end
