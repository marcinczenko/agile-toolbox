//
//  EPQuestionsDataSourceTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/7/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPQuestionsDataSource.h"
#import "EPConnectionDelegateProtocol.h"

@interface EPQuestionsDataSourceTests : XCTestCase

@property (nonatomic,readonly) id doesNotMatter;

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
//        NSDateFormatter *df = [NSDateFormatter new];
//        [df setDateFormat:@"dd MM yyyy HH:mm a z"];
//        NSString* timestamp = [df stringFromDate: [NSDate date]];
        
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"item%ld",(long)index],@"content",
                               [NSString stringWithFormat:@"03-01-2013 %0d:%0d",13+index/60,index%60],@"timestamp",[NSString stringWithFormat:@"%d",index], @"id", nil];
        [json_object addObject:dict];
    }
    
    return json_object;
}

- (NSData*) createJSONDataFromJSONArray:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}


-(void)testFetching1stSetOfQuestions
{
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",(long)EPQuestionsDataSource.pageSize]}];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [questions fetch];
    
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
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    // fetch 1st set of questions
    [questions fetch];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    // fetch 2nd set of questions
    [questions fetch];
    
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
    
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    // fetch 1st set of questions
    [questions fetch];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:firstSetOfQuestions]];
    
    // fetch 2nd set of questions
    [questions fetch];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:secondSetOfQuestions]];
    
    // fetch 3rd set of questions
    [questions fetch];
    
    [connectionMock verify];
}

- (void)testNumberOfQuestionsBeforeAnyDataAreDownloadedShouldBeZero
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    XCTAssertEqual(@[].count,questions.length, @"Before loading any data the length should be 0!");
}

- (void)testThatTheDelegateOfTheConnectionObjectIsSet
{
    __block EPQuestionsDataSource *delegate;
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [connectionMock verify];
    
    XCTAssertEqualObjects(questions, delegate, @"Wrong delegate passed to connection object.");
}

- (void)testThatNumberOfDownloadedQuestionsIsCorrect
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:5];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertEqual(jsonArray.count, questions.length,@"Incorrect number of objects returned.");
}

- (void)testReceivedQuestionsAreTheSameAsTheQuestionsSentFromTheServer
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:10];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    int index = 0;
    for (NSDictionary* questionObject in jsonArray) {
        XCTAssertEqualObjects([questionObject objectForKey:@"content"], [questions questionAtIndex:index]);
        index++;
    }
}

- (void)testRegisteringDataSourceDelegate
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[[dataSourceDelegateMock expect] ignoringNonObjectArgs] questionsFetchedFromIndex:0 to:0];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:[self generateTestJSONArrayWith:5]]];
    
    [dataSourceDelegateMock verify];
    
}

- (void)testDataSourceDelegateIsCalledWithAppropriateIndexesFor1stPage
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:jsonArray.count-1];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [dataSourceDelegateMock verify];
    
}

- (void)testDataSourceDelegateIsCalledWithAppropriateIndexesFor2ndPage
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:jsonArray.count-1];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:jsonArray.count to:2*jsonArray.count-1];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [questions questionAtIndex:questions.nextPageIndexTreshold];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [dataSourceDelegateMock verify];
    
}

- (void)testThatDataSourceDelegateIsCalledEvenWhenNoQuestionsFetched
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:0];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:-1];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [dataSourceDelegateMock verify];
}

- (void)testThatDataSourceDelegateIsCalledWhenNoQuestionsAreFetchedForIndexesGreaterThanZero
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:10];
    NSArray* jsonArrayEmpty = [self generateTestJSONArrayWith:0];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [dataSourceDelegateMock setExpectationOrderMatters:YES];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:9];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:10 to:9];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArrayEmpty]];
    
    [dataSourceDelegateMock verify];
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedNoQuestions
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = @[];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(questions.hasMoreQuestionsToFetch);
}


- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedLessThanOnePageOfQuestions
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage-1];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(questions.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToNOWhenLastFetchReturnedExactlyOneQuestion
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:1];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertFalse(questions.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToYESWhenLastFetchReturnedExactlyOnePageOfQuestions
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertTrue(questions.hasMoreQuestionsToFetch);
}

- (void)testThatDataSourceSetsHasMoreQuestionsToFetchToYESWhenLastFetchReturnedMoreThanOnePageOfQuestions
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage+1];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertTrue(questions.hasMoreQuestionsToFetch);
}



- (void)testThatDataSourceDelegateIsCalledWhenOnlyOneQuestionIsFetched
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:1];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:0];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [dataSourceDelegateMock verify];
}

- (void)testThatDataSourceDelegateIsCalledWhenOnlyOneQuestionIsFetchedForIndexesGreaterThanZero
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:10];
    NSArray* jsonArrayWithOneElement = [self generateTestJSONArrayWith:1];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [dataSourceDelegateMock setExpectationOrderMatters:YES];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:0 to:9];
    [[dataSourceDelegateMock expect] questionsFetchedFromIndex:10 to:10];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArrayWithOneElement]];
    
    [dataSourceDelegateMock verify];
}





@end
