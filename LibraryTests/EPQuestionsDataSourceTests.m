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
    
    for (NSInteger index=0; index<numberOfObjects; index++) {
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"item%ld",(long)index],@"content", nil];
        [json_object addObject:dict];
    }
    
    return json_object;
}

- (NSData*) createJSONDataFromJSONArray:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}


- (void)testThatQATDataSourceStartsLoadingDataUsingSuppliedConnectionProtocol
{
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] start];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [questions downloadData];
    
    [connectionMock verify];
    
}

- (void)testFetching1stPage
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    id partialQuestionsMock = [OCMockObject partialMockForObject:questions];
    
    [[partialQuestionsMock expect] fetchPage:1];
    
    [questions fetch];
    
    [partialQuestionsMock verify];
}

- (void)testFetching2ndPageAfter1stPageIsFetched
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:40];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    id partialQuestionsMock = [OCMockObject partialMockForObject:questions];
    
    [[partialQuestionsMock expect] fetchPage:2];
    
    [questions fetch];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [questions questionAtIndex:20];
    
    [partialQuestionsMock verify];
}

- (void)testConsecutivePageFetches
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:40];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertEqual(jsonArray.count, questions.length);
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertEqual(jsonArray.count*2, questions.length);
}

- (void)testFetching3rdPageAfter2ndPageIsFetched
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:questions.questionsPerPage];
    
    id partialQuestionsMock = [OCMockObject partialMockForObject:questions];
    
    [[partialQuestionsMock expect] fetchPage:3];
    
    [questions fetch];
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [questions questionAtIndex:questions.nextPageIndexTreshold];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [questions questionAtIndex:questions.questionsPerPage*2-questions.nextPageIndexTreshold];
    
    [partialQuestionsMock verify];
}


-(void)testThatFetchingPagesUsesCorrectURL
{
    NSUInteger pageNumberToFetch = 1;
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"page": [NSString stringWithFormat:@"%lu",(long)pageNumberToFetch]}];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [questions fetchPage:pageNumberToFetch];
    
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

- (void) testThatDataSourceDelegateIsNotCalledWhenNoQuestionsFetched
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    NSArray* jsonArray = [self generateTestJSONArrayWith:0];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    [dataSourceDelegateMock verify];
}




@end
