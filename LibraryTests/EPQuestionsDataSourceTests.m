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

- (NSData*) createJSONDataFromJSONObject:(id) json_object;
- (NSArray*) generateTestJSONObjectWith:(NSInteger)numberOfObjects;


@end

@implementation EPQuestionsDataSourceTests

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"https://example.com"];
}

- (id) doesNotMatter
{
    return nil;
}

- (NSArray*) generateTestJSONObjectWith:(NSInteger)numberOfObjects
{
    NSMutableArray* json_object = [NSMutableArray arrayWithCapacity:3];
    
    for (NSInteger index=0; index<numberOfObjects; index++) {
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"item%ld",(long)index],@"content", nil];
        [json_object addObject:dict];
    }
    
    return json_object;
}

- (NSData*) createJSONDataFromJSONObject:(id) json_object
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

- (void)testNumberOfQuestionsBeforeAnyDataAreDownloadedShouldBeZero
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    XCTAssertEqual((int)questions.length, 0,@"Before loading any data the length should be 0!");
    
}

- (void)testThatTheDelegateOfTheConnectionObjectIsSet
{
    __block EPQuestionsDataSource *delegate;
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [connectionMock verify];
    
    XCTAssertEqualObjects(delegate, questions,@"Wrong delegate passed to connection object.");
}

- (void)testThatNumberOfDownloadedQuestionsIsCorrect
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:5]]];
    
    XCTAssertEqual(5, (int)questions.length,@"Incorrect number of objects returned.");
}

- (void)testReceivedQuestionsAreTheSameAsTheQuestionsSentFromTheServer
{
    EPQuestionsDataSource *questions = [[EPQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:3]]];
    
    NSUInteger index = 0;
    for (NSDictionary* questionObject in [self generateTestJSONObjectWith:3]) {
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
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:5]]];
    
    [dataSourceDelegateMock verify];
    
}

@end
