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
@property (nonatomic,strong) id questionsPartialMock;
@property (nonatomic,strong) id dataSourceDelegateMock;
@property (nonatomic,strong) id persistentStoreHelperMock;

@property (nonatomic,strong) id connectionMock;

- (NSData*) createJSONDataFromJSONArray:(id) json_object;
- (NSArray*) generateTestJSONArrayWith:(NSInteger)numberOfObjects;


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

- (NSArray*) generateTestJSONArrayWith:(NSInteger)numberOfObjects
{
    NSMutableArray* json_object = [NSMutableArray arrayWithCapacity:numberOfObjects];
    
    for (int index=(int)numberOfObjects; index>0; index--) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"dd MM yyyy HH:mm:ss.SSSSSS ZZZZ"];
        NSDate *date = [df dateFromString:@"11 01 2014 13:05:00.945000 GMT"];
        NSNumber *dateAsANumber = [NSNumber numberWithDouble:[date timeIntervalSince1970]+(index/60.0)];
        
        
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"item%ld",(long)index],@"content",
                               dateAsANumber,@"timestamp",[NSNumber numberWithInt:index], @"id", nil];
        [json_object addObject:dict];
    }
    
    return json_object;
}

- (NSData*) createJSONDataFromJSONArray:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
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
    NSSortDescriptor *timestampSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    fetchRequest.sortDescriptors = @[timestampSort];
    
    NSError *requestError = nil;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
}

- (void)simulateEnteringBackgroundMode
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

-(void)mockOutCallingCoreDataFor:(id)questions
{
    self.questionsPartialMock = [OCMockObject partialMockForObject:questions];
    [[self.questionsPartialMock stub] saveToCoreData:[OCMArg any]];
}


-(EPQuestionsDataSource*)createQuestionsDataSourceWithConnectio:(id)connection
{
    return [[EPQuestionsDataSource alloc] initWithConnection:connection
                           andWithManagedObjectContext:self.managedObjectContext];
}

-(EPQuestionsDataSource*)setupQuestionsWithConnectionMock:(id)connectionMock
{
    [[connectionMock expect] setDelegate:[OCMArg any]];
    return [self createQuestionsDataSourceWithConnectio:connectionMock];
}

-(EPQuestionsDataSource*)setupQuestionsWithNilConnection
{
    return [self createQuestionsDataSourceWithConnectio:nil];
}

-(void)setUp
{
    [self.appDelegate clearPersistentStore];
    
    self.connectionMock = [OCMockObject niceMockForProtocol:@protocol(EPConnectionProtocol)];
    
    self.questionsWithConnectionMock = [self setupQuestionsWithConnectionMock:self.connectionMock];
    self.questionsWithNilConnection = [self setupQuestionsWithNilConnection];
    
    self.dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    
    self.persistentStoreHelperMock = [OCMockObject niceMockForClass:[EPPersistentStoreHelper class]];
}

-(void)tearDown
{
    self.persistentStoreHelperMock = nil;
}

-(void)testFetching1stSetOfQuestions
{
    [[self.connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    
    [self.questionsWithConnectionMock fetchOlderThan:-1];
    
    [self.connectionMock verify];
}

-(void)testFetchingQuestionsOlderThanTimestampOfAnElementWithTheGivenId
{
    int anID = 123;
    [self.connectionMock setExpectationOrderMatters:YES];
    [[self.connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                              @"id": [NSString stringWithFormat:@"%d",anID]}];
    
    [self.questionsWithConnectionMock fetchOlderThan:anID];
    
    [self.connectionMock verify];
}

- (void)testThatQuestionsAreProperlySavedToCoreDataOnReception
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:5];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];

    int index = 0;
    for (Question *question in [self getQuestionsFromDataStoreDescending]) {
        XCTAssertEqualObjects(question.content, [jsonArray[index] objectForKey:@"content"]);
        XCTAssertEqualWithAccuracy(question.timestamp.timeIntervalSince1970, [(NSNumber*)([jsonArray[index] objectForKey:@"timestamp"]) doubleValue], 0.001);
        index++;
    }
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
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize-1];
    
    [self mockOutCallingCoreDataFor:self.questionsWithNilConnection];
    
    [self.questionsPartialMock downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(((EPQuestionsDataSource*)self.questionsPartialMock).hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedExactlyOneQuestion
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:1];
    
    [self mockOutCallingCoreDataFor:self.questionsWithNilConnection];
    
    [self.questionsPartialMock downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(((EPQuestionsDataSource*)self.questionsPartialMock).hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToYESWhenLastFetchReturnedExactlyOnePageOfQuestions
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize];
    
    [self mockOutCallingCoreDataFor:self.questionsWithNilConnection];
    
    [self.questionsPartialMock downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertTrue(((EPQuestionsDataSource*)self.questionsPartialMock).hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceCallsFetchReturnedNoDataDelegateWhenNoDataHasBeenFetchedFromTheServer
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoData];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceCallsFetchReturnedNoDataInBackgroundDelegateWhenNoDataHasBeenFetchedFromTheServerAndSystemIsInBackgroundMode
{
    [[self.dataSourceDelegateMock expect] fetchReturnedNoDataInBackground];
    
    [self simulateEnteringBackgroundMode];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceCallsDataChangedInBackgroundWhenDataReceivedInBackground
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:5];
    
    [[self.dataSourceDelegateMock expect] dataChangedInBackground];
    
    [self mockOutCallingCoreDataFor:self.questionsWithNilConnection];
    
    [self simulateEnteringBackgroundMode];
    
    self.questionsWithNilConnection.delegate = self.dataSourceDelegateMock;
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [self.dataSourceDelegateMock verify];
}

- (void)testThatDataSourceDoesNotSaveDataToCoreDataWhenServerReturnsNoAnswers
{
    self.questionsPartialMock = [OCMockObject partialMockForObject:self.questionsWithNilConnection];
    [[self.questionsPartialMock reject] saveToCoreData:[OCMArg any]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
}

- (void)testThatDataSourceStoresItsStateToAFileWhenEnteringBackgroundMode
{
    [[self.persistentStoreHelperMock expect] storeDictionary:@{@"HasMoreQuestionsToFetch":[NSNumber numberWithBool:YES]}
                                                      toFile:[EPQuestionsDataSource persistentStoreFileName]];
    [self simulateEnteringBackgroundMode];
    
    [self.persistentStoreHelperMock verify];
}

- (void)testThatDataSourceRestoresPreviouslyStoredContentWhenHasMoreQuestionsToFetchIsYES
{
    NSDictionary* restoredDictionary = @{@"HasMoreQuestionsToFetch":[NSNumber numberWithBool:YES]};
    [[[self.persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceRestoresPreviouslyStoredContentWhenHasMoreQuestionsToFetchIsNO
{
    NSDictionary* restoredDictionary = @{@"HasMoreQuestionsToFetch":[NSNumber numberWithBool:NO]};
    [[[self.persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenDataDoesNoExist_ForNO
{
    [[[self.persistentStoreHelperMock stub] andReturn: nil] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenDataDoesNoExist_ForYES
{
    [[[self.persistentStoreHelperMock stub] andReturn: nil] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenKeyForHasMoreDataToFetchDoesNotExist_ForNO
{
    NSDictionary* restoredDictionary = @{@"DummyKey":@123};
    [[[self.persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    [self.questionsWithNilConnection downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertFalse(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

- (void)testThatRestoringDataFromPersistantStateIsHarmlessWhenKeyForHasMoreDataToFetchDoesNotExist_ForYES
{
    NSDictionary* restoredDictionary = @{@"DummyKey":@123};
    [[[self.persistentStoreHelperMock stub] andReturn: restoredDictionary] readDictionaryFromFile:[EPQuestionsDataSource persistentStoreFileName]];
    
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
    [self.questionsWithNilConnection restoreFromPersistentStorage];
    XCTAssertTrue(self.questionsWithNilConnection.hasMoreQuestionsToFetch);
}

@end
