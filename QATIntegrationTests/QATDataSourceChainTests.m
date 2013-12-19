//
//  QATDataSourceChainTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATConnection.h"
#import "QATQuestionsDataSource.h"
#import "QATDataSourceDelegateProtocol.h"

@interface QATDataSourceChainTests : XCTestCase<QATDataSourceDelegateProtocol>

@property (nonatomic,strong) id<QATDataSourceProtocol> dataSource;
@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;

@end


@implementation QATDataSourceChainTests
@synthesize dataSource = _dataSource;
@synthesize isDone = _isDone;
@synthesize timeout = _timeout;

- (NSData*) createJSONDataFromJSONObject:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}

#pragma mark - QATDataSourceDelegateProtocol
- (void)dataSoruceLoaded
{
    self.isDone = YES;
}

- (void)tearDown
{
    self.isDone = NO;
    self.timeout = NO;
}

- (void)testThatJSONDataIsCorrectlyLoadedFromTheServer
{
    QATConnection * connection = [[QATConnection alloc] initWithURL:[NSURL URLWithString:@"https://quantumagiletoolbox-dev.appspot.com/items_json"]];
    
    self.dataSource = [[QATQuestionsDataSource alloc] initWithConnection:connection];
    
    [self.dataSource setDelegate:self];
    
    [self.dataSource downloadData];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeOut:) name:@"timeOut" object:self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:
     [NSNotification notificationWithName:@"timeOut" object:self]
                                               postingStyle:NSPostWhenIdle];
    
    self.isDone = NO;
    
    while (!self.isDone && !self.timeout)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
                                                  dateWithTimeIntervalSinceNow:2.0]];
        NSLog(@"Polling...");
    }
    XCTAssertTrue(self.isDone);
    QATQuestionsDataSource* dataSource = (QATQuestionsDataSource*)self.dataSource;
    NSLog(@"%i",dataSource.length);
    for (NSInteger i=0; i<dataSource.length; i++) {
        NSLog(@"objectAtIndex:%i:%@",i,[dataSource questionAtIndex:i]);
    }
}

- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
    
}


                                   
                                   


@end
