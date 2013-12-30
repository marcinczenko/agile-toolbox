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

- (void)testThatFetchNQuestionsCallsAppropriateConnectionMethods
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:10];
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%ld",(long)jsonArray.count]}];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [questions fetch:jsonArray.count];
    
    [connectionMock verify];
}

- (void)testFetchingNFirstAvailableQuestions
{
    NSArray* jsonArray = [self generateTestJSONArrayWith:10];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:jsonArray]];
    
    XCTAssertEqual(jsonArray.count, questions.length, @"Incorrect number of questions reported!");
    
    int index = 0;
    for (NSDictionary* questionObject in jsonArray) {
        XCTAssertEqualObjects([questionObject objectForKey:@"content"], [questions questionAtIndex:index]);
        index++;
    }
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
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:[self generateTestJSONArrayWith:5]]];
    
    int index = 0;
    for (NSDictionary* questionObject in [self generateTestJSONArrayWith:3]) {
        XCTAssertEqualObjects([questionObject objectForKey:@"content"], [questions questionAtIndex:index]);
        index++;
    }
}

- (void)testSettingADelegate
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(EPQuestionsDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] questionsFetched];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONArray:[self generateTestJSONArrayWith:5]]];
    
    [dataSourceDelegateMock verify];
    
}

@end
