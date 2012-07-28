//
//  QATPostURLRequestTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATJSONPostURLRequest.h"

@interface QATPostURLRequestTests : SenTestCase

@end

@implementation QATPostURLRequestTests

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"https://example.com"];
}

- (NSData*)examplePOSTHTTPBody
{
    NSString * bodyString = @"Example HTTP Body";
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)testThatRequestIsSetupCorrectly
{
    QATJSONPostURLRequest* postRequest = [[QATJSONPostURLRequest alloc] initWithURL:[self exampleURL] body:[self examplePOSTHTTPBody]];
    
    STAssertEqualObjects([[NSString alloc] initWithData:postRequest.HTTPBody encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:self.examplePOSTHTTPBody encoding:NSUTF8StringEncoding],nil);
    STAssertEqualObjects(@"POST", postRequest.HTTPMethod,nil);
    STAssertEqualObjects(@"application/json", [postRequest valueForHTTPHeaderField:@"Content-Type"],nil);
}

- (void)testCreatingPostRequestWithEmptyBodySoThatItCanBeSetLater
{
    QATJSONPostURLRequest* postRequest = [[QATJSONPostURLRequest alloc] initWithURL:[self exampleURL]];
    
    STAssertNil(postRequest.HTTPBody,nil);
    STAssertEqualObjects(@"POST", postRequest.HTTPMethod,nil);
    STAssertEqualObjects(@"application/json", [postRequest valueForHTTPHeaderField:@"Content-Type"],nil);
}

@end
