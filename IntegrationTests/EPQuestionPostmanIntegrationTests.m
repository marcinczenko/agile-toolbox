//
//  EPQuestionPostmanIntegrationTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPJSONPostURLRequest.h"
#import "EPPostmanDelegateProtocol.h"
#import "EPConnection.h"
#import "EPQuestionPostman.h"

@interface EPQuestionPostmanIntegrationTests : XCTestCase<EPPostmanDelegateProtocol>

@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;

@end

@implementation EPQuestionPostmanIntegrationTests
@synthesize isDone = _isDone;
@synthesize timeout = _timeout;

- (void)setUp
{
    [super setUp];
    
    self.isDone = NO;
    self.timeout = NO;
}

- (void)testPostConnectionWithJSON
{
    EPJSONPostURLRequest* postRequest = [[EPJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:9001/new_json_item"]];
    EPConnection* connection = [[EPConnection alloc] initWithURLRequest:postRequest];
    EPQuestionPostman* postman = [[EPQuestionPostman alloc] initWithConnection:connection];
    
    postman.delegate = self;
    
    [postman post:@"new item"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeOut:) name:@"timeOut" object:self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:
     [NSNotification notificationWithName:@"timeOut" object:self]
                                               postingStyle:NSPostWhenIdle];
    
    while (!self.isDone && !self.timeout)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
                                                  dateWithTimeIntervalSinceNow:2.0]];
        NSLog(@"Polling...");
    }
    XCTAssertTrue(self.isDone);
}

#pragma mark - EPPostmanDelegateProtocol
- (void)postDelivered
{
    NSLog(@"DELIVERED");
    self.isDone = YES;
    
}

- (void)postDeliveryFailed
{
    // TODO: not yet supported
    
}

- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
    
}

@end
