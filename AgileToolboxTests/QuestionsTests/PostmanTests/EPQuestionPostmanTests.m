//
//  EPQuestionPostmanTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPQuestionPostman.h"
#import "EPJSONPostURLRequest.h"
#import "EPConnection.h"
#import "EPPostmanDelegateProtocol.h"

@interface EPQuestionPostmanTests : XCTestCase

@property (nonatomic,readonly) NSURL* exampleURL;
@property (nonatomic,readonly) NSString *testItemString;
@property (nonatomic,readonly) NSString *testQuestionHeader;
@property (nonatomic,readonly) NSString *testQuestionContent;
@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionPostmanTests

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"https://example.com"];
}

- (NSString*)testQuestionHeader
{
    return @"Test Question Header";
}

- (NSString*)testQuestionContent
{
    return @"Test Question Content";
}

- (id)doesNotMatter
{
    return nil;
}

- (NSArray*)createTestJSONObjectForPOSTRequestWithHeader:(NSString*)header content:(NSString*)content
{
    return [NSArray arrayWithObject:@{@"header": header,
                                      @"content":content}];
}

- (NSData*)createJSONDataFromJSONObject:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}

- (NSData*)dataFromString:(NSString*)string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}


- (void)testThatPostmanIsCreatedWithAJSONPOSTConnectionObject
{
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.exampleURL];
    // Currently postman does not check for those properties so this serves as additional
    // documentation before finding out a more healthy solution to this situation.
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    id connection = [OCMockObject niceMockForProtocol:@protocol(EPConnectionProtocol)];
    [[[connection stub] andReturn:urlRequest] urlRequest];
    EPQuestionPostman * postman = [[EPQuestionPostman alloc] initWithConnection:connection];
    XCTAssertNotNil(postman);
}

//---TODO: maybe throwing an exception if the URLRequest is not mutable, not JSON type and not POST method
//- (void)testThatPostmanWillThrowAndExceptionIfCreatedWithWrongConnectionObject
//{
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.exampleURL];
//    [urlRequest setHTTPMethod:@"POST"];
//    
//    id connection = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
//    [[[connection stub] andReturn:urlRequest] urlRequest];
//    STAssertThrowsSpecificNamed([[EPQuestionPostman alloc] initWithConnection:connection], <#specificException#>, <#aName...#><#expr, specificException...#>)
//}

- (void)testThatPostmanCanPost
{
    id connection = [OCMockObject niceMockForProtocol:@protocol(EPConnectionProtocol)];
    [[connection expect] startPOSTWithBody:[OCMArg checkWithBlock:^(id actual) {
        NSData* expected = [self createJSONDataFromJSONObject:[self createTestJSONObjectForPOSTRequestWithHeader:self.testQuestionHeader
                                                                                                         content:self.testQuestionContent]];
        if (![expected isEqualToData:(NSData*)actual]) {
            NSLog(@"EXPECTED:%@",[[NSString alloc] initWithData:expected encoding:NSUTF8StringEncoding]);
            NSLog(@"ACTUAL:%@",[[NSString alloc] initWithData:(NSData*)actual encoding:NSUTF8StringEncoding]);
            return NO;
        }
        return YES;
    }]];
    
    EPQuestionPostman * postman = [[EPQuestionPostman alloc] initWithConnection:connection];
    
    [postman postQuestionWithHeader:self.testQuestionHeader content:self.testQuestionContent];
    
    [connection verify];
}

- (void)testThatPostmanRegistersItselfAsTheDelegateForTheConnectionObject
{
    __block EPQuestionPostman *delegate;
    
    id connection = [OCMockObject mockForProtocol:@protocol(EPConnectionProtocol)];
    [[connection expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    EPQuestionPostman *postman = [[EPQuestionPostman alloc] initWithConnection:connection];
    
    [connection verify];
    
    XCTAssertEqualObjects(delegate, postman,@"Wrong delegate passed to connection object.");
}

- (void)testPostmanDelegateIsCalledOnSuccess
{
    id postmanDelegate = [OCMockObject mockForProtocol:@protocol(EPPostmanDelegateProtocol)];
    [[postmanDelegate expect] postDelivered];
    EPQuestionPostman *postman = [[EPQuestionPostman alloc] initWithConnection:self.doesNotMatter];
    
    postman.delegate = postmanDelegate;
    
    [postman downloadCompleted:[self dataFromString:@"ADDED"]];
    
    [postmanDelegate verify];
}

- (void)testPostmanDelegateIsCalledOnWrongResponseFromServer
{
    id postmanDelegate = [OCMockObject mockForProtocol:@protocol(EPPostmanDelegateProtocol)];
    [[postmanDelegate expect] postDeliveryFailed];
    EPQuestionPostman *postman = [[EPQuestionPostman alloc] initWithConnection:self.doesNotMatter];
    
    postman.delegate = postmanDelegate;
    
    [postman downloadCompleted:[self dataFromString:@"I am a bad bad server!"]];
    
    [postmanDelegate verify];
}

- (void)testPostmanDelegateIsCalledOnFailedConnection
{
    id postmanDelegate = [OCMockObject mockForProtocol:@protocol(EPPostmanDelegateProtocol)];
    [[postmanDelegate expect] postDeliveryFailed];
    EPQuestionPostman *postman = [[EPQuestionPostman alloc] initWithConnection:self.doesNotMatter];
    
    postman.delegate = postmanDelegate;
    
    [postman downloadFailed];
    
    [postmanDelegate verify];
}

@end
