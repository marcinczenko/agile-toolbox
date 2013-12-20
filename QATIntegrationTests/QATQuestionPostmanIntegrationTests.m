//
//  QATQuestionPostmanIntegrationTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATJSONPostURLRequest.h"
#import "QATPostmanDelegateProtocol.h"
#import "QATConnection.h"
#import "QATQuestionPostman.h"

@interface QATQuestionPostmanIntegrationTests : XCTestCase<QATPostmanDelegateProtocol>

@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;

@end

@implementation QATQuestionPostmanIntegrationTests
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
    QATJSONPostURLRequest* postRequest = [[QATJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://quantumagiletoolbox-dev.appspot.com/new_json_item"]];
    QATConnection* connection = [[QATConnection alloc] initWithURLRequest:postRequest];
    QATQuestionPostman* postman = [[QATQuestionPostman alloc] initWithConnection:connection];
    
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

#pragma mark - QATPostmanDelegateProtocol
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
