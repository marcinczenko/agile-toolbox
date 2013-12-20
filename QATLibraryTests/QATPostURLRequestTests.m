//
//  QATPostURLRequestTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATJSONPostURLRequest.h"

@interface QATPostURLRequestTests : XCTestCase

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
    
    XCTAssertEqualObjects([[NSString alloc] initWithData:postRequest.HTTPBody encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:self.examplePOSTHTTPBody encoding:NSUTF8StringEncoding]);
    XCTAssertEqualObjects(@"POST", postRequest.HTTPMethod);
    XCTAssertEqualObjects(@"application/json", [postRequest valueForHTTPHeaderField:@"Content-Type"]);
}

- (void)testCreatingPostRequestWithEmptyBodySoThatItCanBeSetLater
{
    QATJSONPostURLRequest* postRequest = [[QATJSONPostURLRequest alloc] initWithURL:[self exampleURL]];
    
    XCTAssertNil(postRequest.HTTPBody);
    XCTAssertEqualObjects(@"POST", postRequest.HTTPMethod);
    XCTAssertEqualObjects(@"application/json", [postRequest valueForHTTPHeaderField:@"Content-Type"]);
}

@end
