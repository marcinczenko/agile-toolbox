//
//  EPQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPQuestionsDataSource.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPPersistentStoreHelper.h"

#import "Question.h"
#import "EPAppDelegate.h"

@interface EPQuestionsDataSource ()

@property (nonatomic,strong) id<EPConnectionProtocol> connection;

@property (nonatomic,assign) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation EPQuestionsDataSource

+ (NSUInteger)pageSize
{
    return 40;
}

+ (NSString*)persistentStoreFileName
{
    return @"QuestionsDataSource.xml";
}

+ (NSString*)hasMoreQuestionsToFetchKey
{
    return @"HasMoreQuestionsToFetch";
}

- (NSString*) connectionURL
{
    return [self.connection urlString];
}

- (id)initWithConnection:(id<EPConnectionProtocol>)connection andWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    self = [super init];
    
    if (self) {
        _connection = connection;
        [_connection setDelegate:self];
        _hasMoreQuestionsToFetch = YES;
        _managedObjectContext = managedObjectContext;
        _backgroundFetchMode = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)storeToPersistentStorage
{
    NSDictionary* dataDictionary = @{[self.class hasMoreQuestionsToFetchKey]:[NSNumber numberWithBool:self.hasMoreQuestionsToFetch]};
    [EPPersistentStoreHelper storeDictionary:dataDictionary toFile:[self.class persistentStoreFileName]];
}

- (void)restoreFromPersistentStorage
{
    NSDictionary* dataDictionary = [EPPersistentStoreHelper readDictionaryFromFile:[self.class persistentStoreFileName]];
    
    if (dataDictionary) {
        if (dataDictionary[@"HasMoreQuestionsToFetch"]) {
            NSNumber* boolNumber = dataDictionary[@"HasMoreQuestionsToFetch"];
            self.hasMoreQuestionsToFetch = boolNumber.boolValue;
        }
    }
}

- (void)setPostConnection:(id<EPConnectionProtocol>)connection
{
    
}

- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    self.backgroundTaskId = UIBackgroundTaskInvalid;
}

- (void)fetchWithParams:(NSDictionary*)params
{
    UIApplication* app = [UIApplication sharedApplication];
    
    self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    [self.connection getAsynchronousWithParams:params];
}

- (void)fetchOlderThan:(NSInteger)questionId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"n": [NSString stringWithFormat:@"%lu",
                                                                                         (unsigned long)[self.class pageSize]]}];
    if (0 <= questionId) {
        [params addEntriesFromDictionary:@{@"before": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
    }
    
    [self fetchWithParams:params];
}

- (void)fetchNewerThan:(NSInteger)questionId
{
    [self fetchWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                   (unsigned long)[self.class pageSize]],
                            @"after": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
}

- (void)addToManagedObjectContextFromDictionary:(NSDictionary *)questionDictionaryObject
{
    Question *newQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.managedObjectContext];
    
    if (nil != newQuestion) {
        newQuestion.question_id = [questionDictionaryObject objectForKey:@"id"];
        newQuestion.content = [questionDictionaryObject objectForKey:@"content"];
        double ts = [[questionDictionaryObject objectForKey:@"created"] doubleValue];
        newQuestion.created = [NSDate dateWithTimeIntervalSince1970:ts];
    } else {
        NSLog(@"Failed to create the new question core data object.");
    }
}

- (void)saveToCoreData:(NSArray*)questionsArray
{
    for (NSDictionary *questionDictionaryObject in questionsArray) {
        [self addToManagedObjectContextFromDictionary:questionDictionaryObject];
    }
    NSError *savingError = nil;
    
    if ([self.managedObjectContext save:&savingError]) {
        NSLog(@"Successfully saved the context.");
    } else {
        NSLog(@"Failed to save the context. Error = %@", savingError);
    }
}

- (void)callFetchReturnedNoDataDelegate
{
    if (self.backgroundFetchMode) {
        if ([self.delegate respondsToSelector:@selector(fetchReturnedNoDataInBackground)]) {
            [self.delegate fetchReturnedNoDataInBackground];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(fetchReturnedNoData)]) {
            [self.delegate fetchReturnedNoData];
        }
    }
}

- (void)callDataChangedInBackgroundWhenInBackground
{
    if (self.backgroundFetchMode) {
        if ([self.delegate respondsToSelector:@selector(dataChangedInBackground)]) {
            [self.delegate dataChangedInBackground];
        }
    }
}

- (void)downloadCompleted:(NSData *)data
{
    NSArray *new_data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"old"];
    
    if ([self.class pageSize] > new_data.count) {
        _hasMoreQuestionsToFetch = NO;
    }

    if (0==new_data.count) {
        [self callFetchReturnedNoDataDelegate];
    } else {
        [self saveToCoreData:new_data];
        [self callDataChangedInBackgroundWhenInBackground];
        
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    self.backgroundTaskId = UIBackgroundTaskInvalid;
}

- (void) downloadFailed
{
    if (self.backgroundFetchMode) {
        if ([self.delegate respondsToSelector:@selector(connectionFailureInBackground)]) {
            [self.delegate connectionFailureInBackground];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(connectionFailure)]) {
            [self.delegate connectionFailure];
        }
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    self.backgroundTaskId = UIBackgroundTaskInvalid;
}

@end
