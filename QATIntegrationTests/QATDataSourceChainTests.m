//
//  QATDataSourceChainTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATConnection.h"
#import "QATQuestionsDataSource.h"
#import "QATDataSourceDelegateProtocol.h"
 

@interface QATDataSourceChainTests : SenTestCase<QATDataSourceDelegateProtocol>

@property (nonatomic,strong) id<QATDataSourceProtocol> dataSource;
@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;

@end


@implementation QATDataSourceChainTests
@synthesize dataSource = _dataSource;
@synthesize isDone = _isDone;
@synthesize timeout = _timeout;

- (void)dataSoruceLoaded
{
    self.isDone = YES;
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
                                                  dateWithTimeIntervalSinceNow:1.0]];
        NSLog(@"Polling...");
    }
    STAssertTrue(self.isDone,nil);
    NSLog(@"%i",((QATQuestionsDataSource*)self.dataSource).length);
}

- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
    
}


@end
