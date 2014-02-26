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
    [self saveToCoreData];
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

- (void)fetchOlderThan:(NSString*)questionId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"n": [NSString stringWithFormat:@"%lu",
                                                                                         (unsigned long)[self.class pageSize]]}];
    if (questionId) {
        [params addEntriesFromDictionary:@{@"before": questionId}];
    }
    
    [self fetchWithParams:params];
}

- (void)fetchNewAndUpdatedGivenMostRecentQuestionId:(NSString*)mostRecentQuestionId
                                   oldestQuestionId:(NSString*)oldestQuestionId
                                          timestamp:(NSString*)timestamp
{
    [self fetchWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                   (unsigned long)[self.class pageSize]],
                            @"newest": mostRecentQuestionId,
                            @"oldest": oldestQuestionId,
                            @"timestamp": timestamp}];
}

- (void)addToManagedObjectContextFromDictionary:(NSDictionary *)questionDictionaryObject
{
    Question *aQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.managedObjectContext];
    
    if (nil != aQuestion) {
        aQuestion.question_id = [questionDictionaryObject objectForKey:@"id"];
        
        [self updateQuestion:aQuestion withJsonDictionary:questionDictionaryObject];
        
    } else {
        NSLog(@"Failed to create the new question core data object.");
    }
}

- (void)addToCoreData:(NSArray*)questionsArray
{
    for (NSDictionary *questionDictionaryObject in questionsArray) {
        [self addToManagedObjectContextFromDictionary:questionDictionaryObject];
    }
}

- (void)saveToCoreData
{
    if (self.managedObjectContext.hasChanges) {
        NSError *savingError = nil;
        
        if ([self.managedObjectContext save:&savingError]) {
            NSLog(@"Successfully saved the context.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
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

- (NSDictionary*)makeDictionaryKeyedByIdForJsonQuestions:(NSArray*)jsonQuestions
{
    NSMutableDictionary* wrapperDictionary = [NSMutableDictionary new];
    for (NSDictionary* jsonDictionary in jsonQuestions) {
        wrapperDictionary[jsonDictionary[@"id"]] = jsonDictionary;
    }
    return wrapperDictionary;
}

- (NSArray*)fetchQuestionsWithQuestionIdsIn:(NSArray*)questionIds
{
    NSPredicate *inPredicate = [NSPredicate predicateWithFormat: @"question_id IN %@", questionIds];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    fetchRequest.sortDescriptors = @[createdSort];
    fetchRequest.predicate = inPredicate;
    
    NSError *requestError = nil;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
}

- (void)updateQuestion:(Question*)question withJsonDictionary:(NSDictionary*)dictionary
{
    question.header = [dictionary objectForKey:@"header"];
    question.content = [dictionary objectForKey:@"content"];
    question.created = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created"] doubleValue]];
    question.updated = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"updated"] doubleValue]];
    id answer = [dictionary objectForKey:@"answer"];
    if ([NSNull null] != answer) {
        question.answer = answer;
    }
    question.updatedOrNew = @YES;
}

- (void)synchronizeCoreDataQuestionsWithJsonArray:(NSArray*)jsonArray
{
    NSDictionary* wrapperDictionary = [self makeDictionaryKeyedByIdForJsonQuestions:jsonArray];
    for (Question* question in [self fetchQuestionsWithQuestionIdsIn:wrapperDictionary.allKeys]) {
        [self updateQuestion:question withJsonDictionary:wrapperDictionary[question.question_id]];
    }
}

- (void)handleNew:(NSArray*)newQuestions andUpdated:(NSArray*)updatedQuestions
{
    // if newQuestions is not null than updatedQuestions is not null by design
    // receivedData[@"new"] should only be null during fetchOlderThan
    // othrewise it may be of zero length but should not be null
    if (newQuestions) {
        if (0==newQuestions.count && 0==updatedQuestions.count) {
            [self callFetchReturnedNoDataDelegate];
        } else {
            [self handleNewQuestions:newQuestions];
            [self handleUpdatedQuestions:updatedQuestions];
            [self callDataChangedInBackgroundWhenInBackground];
        }
    }
}

- (void) handleNewQuestions:(NSArray*)newQuestions
{
    if (0<newQuestions.count) {
        [self addToCoreData:newQuestions];
    }
}

- (void)handleUpdatedQuestions:(NSArray*)updatedQuestions
{
    if (0<updatedQuestions.count) {
        
        [self synchronizeCoreDataQuestionsWithJsonArray:updatedQuestions];
    }
}

- (void) handleOldQuestions:(NSArray*)oldQuestions
{
    if (oldQuestions) {
        if ([self.class pageSize] > oldQuestions.count) {
            _hasMoreQuestionsToFetch = NO;
        }
        
        if (0==oldQuestions.count) {
            [self callFetchReturnedNoDataDelegate];
        } else {
            [self addToCoreData:oldQuestions];
            [self callDataChangedInBackgroundWhenInBackground];
        }
    }
}

- (void)downloadCompleted:(NSData *)data
{
    NSDictionary* receivedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (!receivedData[@"old"] && !receivedData[@"new"]) {
        [self downloadFailed];
        return;
    }
    
    [self handleOldQuestions:receivedData[@"old"]];
    [self handleNew:receivedData[@"new"] andUpdated:receivedData[@"updated"]];
    
    [self saveToCoreData];
    
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
