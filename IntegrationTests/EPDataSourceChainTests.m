//
//  EPDataSourceChainTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPConnection.h"
#import "EPQuestionsDataSource.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"

@interface EPDataSourceChainTests : XCTestCase<EPQuestionsDataSourceDelegateProtocol>

@property (nonatomic,strong) id<EPQuestionsDataSourceProtocol> dataSource;
@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;

@end


@implementation EPDataSourceChainTests
@synthesize dataSource = _dataSource;
@synthesize isDone = _isDone;
@synthesize timeout = _timeout;

- (NSData*) createJSONDataFromJSONObject:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}

#pragma mark - EPDataSourceDelegateProtocol
- (void)questionsFetched
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
    EPConnection * connection = [[EPConnection alloc] initWithURL:[NSURL URLWithString:@"http://localhost:9001/items_json"]];
    
    self.dataSource = [[EPQuestionsDataSource alloc] initWithConnection:connection];
    
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
    EPQuestionsDataSource* dataSource = (EPQuestionsDataSource*)self.dataSource;
    NSLog(@"%ld",(long)dataSource.length);
    for (NSInteger i=0; i<dataSource.length; i++) {
        NSLog(@"objectAtIndex:%ld:%@",(long)i,[dataSource questionAtIndex:i]);
    }
}

- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
    
}


                                   
                                   


@end
