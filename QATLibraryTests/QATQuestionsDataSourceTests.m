//
//  QATQuestionsDataSourceTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/7/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATQuestionsDataSource.h"
#import "QATConnectionDelegateProtocol.h"

@interface QATQuestionsDataSourceTests : SenTestCase

@property (readonly) id doesNotMatter;

- (NSData*) createJSONDataFromJSONObject:(id) json_object;
- (NSArray*) generateTestJSONObjectWith:(NSInteger)numberOfObjects;


@end

@implementation QATQuestionsDataSourceTests

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
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"item%d",index],@"contents", nil];
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
//    QATQuestionsDataSource* questions = [QATQuestionsDataSource questionsDataSourceFromJSONData:[self createJSONDataFromJSONObject:[self generateTestJSONObject]]];
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(QATConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg any]];
    [[connectionMock expect] start];
    
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [questions loadData];
    
    [connectionMock verify];
    
}

- (void)testNumberOfQuestionsBeforeAnyDataAreDownloadedShouldBeZero
{
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    STAssertEquals(questions.length, 0,@"Before loading any data the length should be 0!");
    
}

- (void)testThatTheDelegateOfTheConnectionObjectIsSet
{
    __block QATQuestionsDataSource *delegate;
    
    id connectionMock = [OCMockObject mockForProtocol:@protocol(QATConnectionProtocol)];
    [[connectionMock expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:connectionMock];
    
    [connectionMock verify];
    
    STAssertEqualObjects(delegate, questions,@"Wrong delegate passed to connection object.");
}

- (void)testNumberOfQuestionsAfterDataHasBeenDownloaded
{
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:5]]];
    
    STAssertEquals(5, questions.length,@"Incorrect number of objects returned.");
}

- (void)testQuestionsReflectTheQuestionsSentFromTheServer
{
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:3]]];
    
    NSUInteger index = 0;
    for (NSDictionary* questionObject in [self generateTestJSONObjectWith:3]) {
        STAssertEqualObjects([questionObject objectForKey:@"contents"], [questions questionAtIndex:index],nil);
        index++;
    }
}

- (void)testSettingADelegate
{
    QATQuestionsDataSource *questions = [[QATQuestionsDataSource alloc] initWithConnection:self.doesNotMatter];
    
    id dataSourceDelegateMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceDelegateProtocol)];
    [[dataSourceDelegateMock expect] dataSoruceLoaded];
    
    [questions setDelegate:dataSourceDelegateMock];
    
    [questions downloadCompleted:[self createJSONDataFromJSONObject:[self generateTestJSONObjectWith:5]]];
    
    [dataSourceDelegateMock verify];
    
}

@end
