//
//  QATQuestionPostmanTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATQuestionPostman.h"
#import "QATJSONPostURLRequest.h"
#import "QATConnection.h"
#import "QATPostmanDelegateProtocol.h"

@interface QATQuestionPostmanTests : SenTestCase

@property (nonatomic,readonly) NSURL* exampleURL;
@property (nonatomic,readonly) NSString *testItemString;
@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation QATQuestionPostmanTests

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"https://example.com"];
}

- (NSString*)testItemString
{
    return @"New Item";
}

- (id)doesNotMatter
{
    return nil;
}

- (NSArray*)createTestJSONObjectForPOSTRequestWithString:(NSString*)item
{
    return [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:item forKey:@"content"]];
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
    
    id connection = [OCMockObject niceMockForProtocol:@protocol(QATConnectionProtocol)];
    [[[connection stub] andReturn:urlRequest] urlRequest];
    QATQuestionPostman * postman = [[QATQuestionPostman alloc] initWithConnection:connection];
    STAssertNotNil(postman,nil);
}

//---TODO: maybe throwing an exception if the URLRequest is not mutable, not JSON type and not POST method
//- (void)testThatPostmanWillThrowAndExceptionIfCreatedWithWrongConnectionObject
//{
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.exampleURL];
//    [urlRequest setHTTPMethod:@"POST"];
//    
//    id connection = [OCMockObject mockForProtocol:@protocol(QATConnectionProtocol)];
//    [[[connection stub] andReturn:urlRequest] urlRequest];
//    STAssertThrowsSpecificNamed([[QATQuestionPostman alloc] initWithConnection:connection], <#specificException#>, <#aName...#><#expr, specificException...#>)
//}

- (void)testThatPostmanCanPost
{
    id connection = [OCMockObject niceMockForProtocol:@protocol(QATConnectionProtocol)];
    [[connection expect] startPOSTWithBody:[OCMArg checkWithBlock:^(id actual) {
        NSData* expected = [self createJSONDataFromJSONObject:[self createTestJSONObjectForPOSTRequestWithString:self.testItemString]];
        if (![expected isEqualToData:(NSData*)actual]) {
            NSLog(@"EXPECTED:%@",[[NSString alloc] initWithData:expected encoding:NSUTF8StringEncoding]);
            NSLog(@"ACTUAL:%@",[[NSString alloc] initWithData:(NSData*)actual encoding:NSUTF8StringEncoding]);
            return NO;
        }
        return YES;
    }]];
    
    QATQuestionPostman * postman = [[QATQuestionPostman alloc] initWithConnection:connection];
    
    [postman post:self.testItemString];
    
    [connection verify];
}

- (void)testThatPostmanRegistersItselfAsTheDelegateForTheConnectionObject
{
    __block QATQuestionPostman *delegate;
    
    id connection = [OCMockObject mockForProtocol:@protocol(QATConnectionProtocol)];
    [[connection expect] setDelegate:[OCMArg checkWithBlock:^(id delegateParam) { delegate = delegateParam ; return YES; }]];
    
    QATQuestionPostman *postman = [[QATQuestionPostman alloc] initWithConnection:connection];
    
    [connection verify];
    
    STAssertEqualObjects(delegate, postman,@"Wrong delegate passed to connection object.");
}

- (void)testPostmanDelegateIsCalledOnSuccess
{
    id postmanDelegate = [OCMockObject mockForProtocol:@protocol(QATPostmanDelegateProtocol)];
    [[postmanDelegate expect] postDelivered];
    QATQuestionPostman *postman = [[QATQuestionPostman alloc] initWithConnection:self.doesNotMatter];
    
    postman.delegate = postmanDelegate;
    
    [postman downloadCompleted:[self dataFromString:@"ADDED"]];
    
    [postmanDelegate verify];
}

- (void)testPostmanDelegateIsCalledOnWrongResponseFromServer
{
    id postmanDelegate = [OCMockObject mockForProtocol:@protocol(QATPostmanDelegateProtocol)];
    [[postmanDelegate expect] postDeliveryFailed];
    QATQuestionPostman *postman = [[QATQuestionPostman alloc] initWithConnection:self.doesNotMatter];
    
    postman.delegate = postmanDelegate;
    
    [postman downloadCompleted:[self dataFromString:@"I am a bad bad server!"]];
    
    [postmanDelegate verify];
}

// TODO:
//- (void)testPostmanDelegateIsCalledOnFailedConnection
//{
//    
//}

@end
