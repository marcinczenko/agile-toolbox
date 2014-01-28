//
//  EPQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPQuestionsDataSource.h"
#import "EPQuestionsDataSourceProtocol.h"

#import "Question.h"
#import "EPAppDelegate.h"

@interface EPQuestionsDataSource ()

@property (nonatomic,strong) id<EPConnectionProtocol> connection;

@property (nonatomic,assign) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic,assign) BOOL applicationRunsInBackground;

@property (nonatomic, strong) NSTimer *myTimer;

@end

@implementation EPQuestionsDataSource

const NSUInteger QUESTIONS_PER_PAGE = 40;

+ (NSUInteger)pageSize
{
    return QUESTIONS_PER_PAGE;
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
        _applicationRunsInBackground = NO;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
        [center addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didEnterBackgroundNotification:(NSNotification*)paramNotification
{
    self.applicationRunsInBackground = YES;
}

- (void)willEnterForegroundNotification:(NSNotification*)paramNotification
{
    self.applicationRunsInBackground = NO;
}


- (void)setPostConnection:(id<EPConnectionProtocol>)connection
{
    
}

- (void)endBackgroundTask
{
    NSLog(@"endBackgroundTask");
    if (![NSThread isMainThread]) {
        NSLog(@"WE ARE NOT IN THE MAIN THREAD!!!!!!!!!!!!!");
    }
    
    [self.myTimer invalidate];        
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    self.backgroundTaskId = UIBackgroundTaskInvalid;
}

- (void) timerMethod:(NSTimer *)paramSender
{
    NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX) {
        NSLog(@"Background Time Remaining = Undetermined");
    }else{
        NSLog(@"Background Time Remaining = %.02f Seconds",backgroundTimeRemaining);
    }
}

- (void)fetchOlderThan:(NSInteger)questionId
{
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self selector:@selector(timerMethod:) userInfo:nil
                                    repeats:NO];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"n": [NSString stringWithFormat:@"%lu",
                                                                                         (unsigned long)QUESTIONS_PER_PAGE]}];
    
    if (0 <= questionId) {
        [params addEntriesFromDictionary:@{@"id": [NSString stringWithFormat:@"%ld",(unsigned long)questionId]}];
    }
    
    [self.connection getAsynchronousWithParams:params];
}

- (void)fetchNew
{
    
}

- (void)addToManagedObjectContextFromDictionary:(NSDictionary *)questionDictionaryObject
{
    Question *newQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.managedObjectContext];
    
    if (nil != newQuestion) {
        newQuestion.question_id = [questionDictionaryObject objectForKey:@"id"];
        newQuestion.content = [questionDictionaryObject objectForKey:@"content"];
        double ts = [[questionDictionaryObject objectForKey:@"timestamp"] doubleValue];
        newQuestion.timestamp = [NSDate dateWithTimeIntervalSince1970:ts];
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

- (void)downloadCompleted:(NSData *)data
{
    NSArray *new_data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (QUESTIONS_PER_PAGE > new_data.count) {
        _hasMoreQuestionsToFetch = NO;
    }

    if (0==new_data.count) {
        if (self.applicationRunsInBackground) {
            if ([self.delegate respondsToSelector:@selector(fetchReturnedNoDataInBackground)]) {
                [self.delegate fetchReturnedNoDataInBackground];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(fetchReturnedNoData)]) {
                [self.delegate fetchReturnedNoData];
            }
        }
    } else {
        [self saveToCoreData:new_data];
        if (self.applicationRunsInBackground) {
            if ([self.delegate respondsToSelector:@selector(dataChangedInBackground)]) {
                [self.delegate dataChangedInBackground];
            }
        }
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    self.backgroundTaskId = UIBackgroundTaskInvalid;
}

- (void) downloadFailed
{
    if (self.applicationRunsInBackground) {
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
