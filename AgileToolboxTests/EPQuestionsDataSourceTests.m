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

@interface EPQuestionsDataSourceTests : XCTestCase

@property (nonatomic,readonly) id doesNotMatter;
@property (nonatomic,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,readonly) NSManagedObjectContext *backgroundContext;
@property (nonatomic,readonly) EPAppDelegate* appDelegate;

@property (nonatomic,strong) EPQuestionsDataSource *questionsWithConnectionMock;
@property (nonatomic,strong) EPQuestionsDataSource *questionsWithNilConnection;
@property (nonatomic,strong) id questionsPartialMock;

@property (nonatomic,strong) id connectionMock;

- (NSData*) createJSONDataFromJSONArray:(id) json_object;
- (NSArray*) generateTestJSONArrayWith:(NSInteger)numberOfObjects;


@end

@implementation EPQuestionsDataSourceTests

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

-(void)mockOutCallingCoreDataFor:(id)questions
{
    self.questionsPartialMock = [OCMockObject partialMockForObject:questions];
    [[self.questionsPartialMock stub] saveToCoreData:[OCMArg any]];
}


-(EPQuestionsDataSource*)createQuestionsDataSourceWithConnectio:(id)connection
{
    return [[EPQuestionsDataSource alloc] initWithConnection:connection
                           andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
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
    
    self.connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    
    self.questionsWithConnectionMock = [self setupQuestionsWithConnectionMock:self.connectionMock];
    self.questionsWithNilConnection = [self setupQuestionsWithNilConnection];
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
    
    [self mockOutCallingCoreDataFor:self.questionsWithConnectionMock];
    
    [self.questionsPartialMock fetchOlderThan:anID];
    
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
                                                       andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
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

- (void)testThatDataSourceCallsTheDelegateWhenNoDataHasBeenFetchedFromTheServer
{
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] fetchReturnedNoData];
    
    [self mockOutCallingCoreDataFor:self.questionsWithNilConnection];
    
    ((EPQuestionsDataSource*)self.questionsPartialMock).delegate = dataSourceDelegateMock;
    [self.questionsPartialMock downloadCompleted:[self createJSONDataFromJSONArray:@[]]];
    
    [dataSourceDelegateMock verify];
}

@end
