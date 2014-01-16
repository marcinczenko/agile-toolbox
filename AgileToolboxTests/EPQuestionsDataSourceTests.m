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

@interface EPQuestionsDataSourceTests : XCTestCase

@property (nonatomic,readonly) id doesNotMatter;
@property (nonatomic,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,readonly) NSManagedObjectContext *backgroundContext;
@property (nonatomic,readonly) EPAppDelegate* appDelegate;

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

-(void)setUp
{
    [self.appDelegate clearPersistentStore];
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


-(void)testFetching1stSetOfQuestions
{
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock
                                                             andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    [questions fetchOlderThan:-1];
    
    [connectionMock verify];
}

-(void)testFetching2ndSetOfQuestions
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize];
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                         @"id": [NSString stringWithFormat:@"%d",1]}];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock
                                                       andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    // fetch 1st set of questions
    [questions fetchOlderThan:-1];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    // fetch 2nd set of questions
    [questions fetchOlderThan:1];
    
    [connectionMock verify];
}

-(void)testFetching3rdSetOfQuestions
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize*2];
    NSArray* firstSetOfQuestions = [jsonArray subarrayWithRange:NSMakeRange(0, EPQuestionsDataSource.pageSize)];
    NSArray* secondSetOfQuestions = [jsonArray subarrayWithRange:NSMakeRange(EPQuestionsDataSource.pageSize, EPQuestionsDataSource.pageSize)];
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                         @"id": [NSString stringWithFormat:@"%ld",(long)EPQuestionsDataSource.pageSize+1]}];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize],
                                                         @"id": [NSString stringWithFormat:@"%d",1]}];
    
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock
                                                       andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    // fetch 1st set of questions
    [questions fetchOlderThan:-1];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:firstSetOfQuestions]];
    
    // fetch 2nd set of questions
    [questions fetchOlderThan:EPQuestionsDataSource.pageSize+1];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:secondSetOfQuestions]];
    
    // fetch 3rd set of questions
    [questions fetchOlderThan:1];
    
    [connectionMock verify];
}

- (NSArray*)getQuestionsFromDataStoreDescending
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *timestampSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    fetchRequest.sortDescriptors = @[timestampSort];
    
    NSError *requestError = nil;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
}

- (void)testThatQuestionsAreSavedToCoreDataOnReception
{
//    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:1389445545.945];
//    
//    NSDateFormatter *df = [NSDateFormatter new];
//    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    [df setDateFormat:@"dd MM yyyy HH:mm:SSSSSS ZZZZ"];
//    NSString* timestamp = [df stringFromDate: dt];
//    
//    NSLog(@"%@",timestamp);
    
    NSArray* jsonArray = [self generateTestJSONArrayWith:5];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:[self doesNotMatter]
                                                       andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];

    int index = 0;
    for (Question *question in [self getQuestionsFromDataStoreDescending]) {
        NSLog(@"question: %@",question.content);
        XCTAssertEqualObjects(question.content, [jsonArray[index] objectForKey:@"content"]);
        XCTAssertEqualWithAccuracy(question.timestamp.timeIntervalSince1970, [(NSNumber*)([jsonArray[index] objectForKey:@"timestamp"]) doubleValue], 0.001);
        index++;
    }
}

//- (NSArray*)extractKey:(id)key from:(NSArray*)array
//{
//    NSMutableArray *keyArray = [NSMutableArray new];
//    [array enumerateObjectsUsingBlock:^(NSDictionary* dict, NSUInteger idx, BOOL *stop) {
//        [keyArray addObject:[dict objectForKey:key]];
//    }];
//    return keyArray;
//}
//
//- (void)expectControllerDidChangeObjectFor:(id)mock and:(NSArray*)array
//{
//    [[mock expect] controller:[OCMArg any] didChangeObject:[OCMArg checkWithBlock:^BOOL(Question * question) {
//        return [[self extractKey:@"content" from:array] containsObject:question.content];
//    }] atIndexPath:[OCMArg any] forChangeType:NSFetchedResultsChangeInsert newIndexPath:[OCMArg any]];
//}

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
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter
                                                             andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize-1];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    // TODO mock out calling Core Data
    
    XCTAssertFalse(questions.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedExactlyOneQuestion
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter
                                                             andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSArray* jsonArray = [self generateTestJSONArrayWith:1];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(questions.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToYESWhenLastFetchReturnedExactlyOnePageOfQuestions
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter
                                                             andWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSArray* jsonArray = [self generateTestJSONArrayWith:EPQuestionsDataSource.pageSize];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertTrue(questions.hasMoreQuestionsToFetch);
}





@end
