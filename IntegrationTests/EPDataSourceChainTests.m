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

@property (nonatomic,readonly) NSString* hostUrl;

- (void)completionBlock:(EPConnection*)connection;

@end

@implementation EPDataSourceChainTests

- (NSString*)hostUrl
{
    return @"http://192.168.1.33:9001";
}

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
    //[self bootstrapFetchedResultsController];
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

- (void)fetchNewAndUpdatedForNewest:(NSUInteger)newestQuestionId oldest:(NSInteger)oldestQuestionId forConnection:(EPConnection*)connection
{
    [connection getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                                   (unsigned long)[EPQuestionsDataSource pageSize]],
                                            @"newest": [NSString stringWithFormat:@"%ld",(unsigned long)newestQuestionId],
                                            @"oldest": [NSString stringWithFormat:@"%ld",(unsigned long)oldestQuestionId]}];
}

- (void)fetchOlderThan:(NSUInteger)questionId forConnection:(EPConnection*)connection
{
    [connection getAsynchronousWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                                   (unsigned long)[EPQuestionsDataSource pageSize]],
                                            @"id": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
}

- (NSData*)getSynchronousFromUrl:(NSString*)url withParams:(NSArray*)params
{
    __block NSString *url_with_params = [url stringByAppendingString:@"?"];
    __block BOOL isFirstParam = YES;
    
    for (NSDictionary* param in params) {
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *format = (isFirstParam) ? @"%@=%@" : @"&%@=%@";
            url_with_params = [url_with_params stringByAppendingFormat:format,key,obj];
            isFirstParam = NO;
        }];
    }
    
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url_with_params]];

    NSURLResponse* response;
    NSError* error;
    return [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
}


- (void)updateQuestionsOnTheServerWithIds:(NSArray*)ids
{
    NSMutableArray* params = [NSMutableArray new];
    for (NSString* question_id in ids) {
        [params addObject:@{@"id": question_id}];
    }
    
    
    NSData* responseData = [self getSynchronousFromUrl:[NSString stringWithFormat:@"%@/update_ids",self.hostUrl]
                                            withParams:params];
    
    if (0 < responseData.length) {
        NSLog(@"Response: %@",[NSString stringWithCString:[responseData bytes]
                                                        encoding:NSUTF8StringEncoding]);
    }
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
    NSDictionary* receivedData = [NSJSONSerialization JSONObjectWithData:[connection receivedData] options:0 error:nil];
    
    NSLog(@"old:%@",receivedData[@"old"]);
    NSLog(@"new:%@",receivedData[@"new"]);
    NSLog(@"updated:%@",receivedData[@"updated"]);
    
    if (receivedData[@"new"]) {
        NSLog(@"%ld",(long)((NSArray*)receivedData[@"new"]).count);
    } else {
        NSLog(@"New is null");
    }
    
    self.isDone = YES;
}

- (void)testFetchingAllQuestionsFromServer
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

- (void)testFetchingNewAndUpdatedQuestionsFromServer
{
    EPConnection * connection = [[EPConnection alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.33:9001/items_json"]
                                                    progressBlock:nil
                                                  completionBlock:^(EPConnection *connection, NSError *error) {
                                                      [self completionBlock:connection];
                                                  }];
    
    [self fetchAllForConnection:connection];
    [self waitForAsynchronousRequest:2.0];
    self.isDone = NO;
    self.timeout = NO;
    
    [self updateQuestionsOnTheServerWithIds:@[@"5",@"3",@"1"]];
    
    connection = [[EPConnection alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.33:9001/items_json"]
                                     progressBlock:nil
                                   completionBlock:^(EPConnection *connection, NSError *error) {
                                       [self completionBlock:connection];
                                   }];
    
    [self fetchNewAndUpdatedForNewest:5 oldest:1 forConnection:connection];
    [self waitForAsynchronousRequest:2.0];
    
    XCTAssertTrue(self.isDone);
}


- (void) timeOut:(NSNotification*)notification;
{
    self.timeout = YES;
}

@end
