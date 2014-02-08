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
#import "EPAppDelegate.h"
#import "Question.h"

@interface EPDataSourceChainTests : XCTestCase<EPQuestionsDataSourceDelegateProtocol,NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) EPQuestionsDataSource* dataSource;
@property (nonatomic,assign) BOOL isDone;
@property (nonatomic,assign) BOOL timeout;
@property (nonatomic,strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic,weak) EPAppDelegate* appDelegate;

- (void)completionBlock:(EPConnection*)connection;

@end


@implementation EPDataSourceChainTests

- (NSData*) createJSONDataFromJSONObject:(id) json_object
{
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:NULL];
}

- (void)bootstrapFetchedResultsController
{
    NSFetchRequest *questionsFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    
    questionsFetchRequest.sortDescriptors = @[createdSort];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:questionsFetchRequest
                                                                                                        managedObjectContext:self.appDelegate.managedObjectContext
                                                                                                          sectionNameKeyPath:nil
                                                                                                                   cacheName:nil];
    NSError *fetchError = nil;
    [self.fetchedResultsController performFetch:&fetchError];
    
    self.fetchedResultsController.delegate = self;
}


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(Question*)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"%@",anObject);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.isDone = YES;
}


#pragma mark - EPDataSourceDelegateProtocol
- (void)fetchReturnedNoData
{
    
}

- (void)fetchReturnedNoDataInBackground
{
    
}

- (void)dataChangedInBackground
{
    
}

- (void)connectionFailure
{
    
}

- (void)connectionFailureInBackground
{
    
}

- (void)setUp
{
    self.isDone = NO;
    self.timeout = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeOut:) name:@"timeOut" object:self];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self bootstrapFetchedResultsController];
}

- (void)tearDown
{
    [self.appDelegate clearPersistentStore];
}

- (void)waitForAsynchronousRequest:(CGFloat) timeoutInSeconds
{
    [[NSNotificationQueue defaultQueue] enqueueNotification:
     [NSNotification notificationWithName:@"timeOut" object:self]
                                               postingStyle:NSPostWhenIdle];
    
    while (!self.isDone && !self.timeout)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
                                                  dateWithTimeIntervalSinceNow:timeoutInSeconds]];
    }
}

- (void)fetchAllForConnection:(EPConnection*)connection
{
    [connection start];
}

- (void)fetchNewerThan:(NSUInteger)questionId forConnection:(EPConnection*)connection
{
    [connection getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                                   (unsigned long)[EPQuestionsDataSource pageSize]],
                                            @"after": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
}

- (void)fetchOlderThan:(NSUInteger)questionId forConnection:(EPConnection*)connection
{
    [connection getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                                   (unsigned long)[EPQuestionsDataSource pageSize]],
                                            @"id": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
}


- (void)testThatJSONDataIsCorrectlyLoadedFromTheServer
{
    EPConnection * connection = [[EPConnection alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.33:9001/items_json"]];
    
    self.dataSource = [[EPQuestionsDataSource alloc] initWithConnection:connection andWithManagedObjectContext:self.appDelegate.managedObjectContext];
    [self.dataSource setDelegate:self];
    [self.dataSource fetchOlderThan:-1];
    
    [self waitForAsynchronousRequest:2.0];
    
    XCTAssertTrue(self.isDone);
    
}

- (void)completionBlock:(EPConnection*)connection
{
    NSArray* receivedData = [NSJSONSerialization JSONObjectWithData:[connection receivedData] options:0 error:nil];
    
    NSLog(@"receivedData(NSData):%@",receivedData);
    
    self.isDone = YES;
}

- (void)testTheStructureOfDataReceivedFromTheServer
{
    EPConnection * connection = [[EPConnection alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.33:9001/items_json"]
                                                    progressBlock:nil
                                                  completionBlock:^(EPConnection *connection, NSError *error) {
                                                      [self completionBlock:connection];
                                                  }];
    
    [self fetchAllForConnection:connection];
    
    [self waitForAsynchronousRequest:2.0];
    
    XCTAssertTrue(self.isDone);
}

- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
}

@end
