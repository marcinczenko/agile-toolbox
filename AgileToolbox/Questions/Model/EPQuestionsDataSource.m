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

@interface Dupa : NSObject

@property (nonatomic, strong) NSDate* updated;

@end

@implementation Dupa

@end

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

- (void)fetchNewAndUpdatedAfterTimestamp:(NSString*)timestamp
{
    [self fetchWithParams:@{@"n": [NSString stringWithFormat:@"%lu",
                                   (unsigned long)[self.class pageSize]],
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
//            for (Question* question in self.delegate.fetchedResultsController.fetchedObjects) {
//                NSLog(@"===Header:%@, created:%@ updated:%@", question.header, question.created, question.updated);
//            }
//            
//            NSMutableArray* array = [self.delegate.fetchedResultsController.fetchedObjects mutableCopy];
//            
//            NSSortDescriptor *updatedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortUpdated" ascending:NO];
//            NSArray *sortDescriptors = @[updatedDescriptor];
//            NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
//            
//            NSMutableArray* dupaArray = [NSMutableArray new];
//            
//            for (Question* question in sortedArray) {
//                Dupa* dupa = [Dupa new];
//                dupa.updated = question.updated;
//                [dupaArray addObject:dupa];
////                NSLog(@"+++Header:%@, created:%@ updated:%@", question.header, question.created, question.updated);
//                NSLog(@"+++updated:%@", question.sortUpdated);
//            }
//            
//            NSSortDescriptor *dupaDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO];
//            NSArray *dupaSortDescriptors = @[dupaDescriptor];
//            NSArray *sortedDupaArray = [dupaArray sortedArrayUsingDescriptors:dupaSortDescriptors];
//            
//            for (Dupa* dupa in sortedDupaArray) {
//                NSLog(@"###dupa:%@", dupa.updated);
//            }
            
            
            
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

- (NSMutableDictionary*)makeDictionaryKeyedByIdForJsonQuestions:(NSArray*)jsonQuestions
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
    question.sortUpdated = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"updated"] doubleValue]];
    id answer = [dictionary objectForKey:@"answer"];
    if ([NSNull null] != answer) {
        question.answer = answer;
    }
    question.updatedOrNew = @YES;
//    NSLog(@"Header:%@, created:%@ updated:%@", question.header, question.created, question.updated);
}

- (void)synchronizeCoreDataQuestionsWithJsonArray:(NSArray*)jsonArray
{
    NSMutableDictionary* wrapperDictionary = [self makeDictionaryKeyedByIdForJsonQuestions:jsonArray];
    for (Question* question in [self fetchQuestionsWithQuestionIdsIn:wrapperDictionary.allKeys]) {
        [self updateQuestion:question withJsonDictionary:wrapperDictionary[question.question_id]];
        [wrapperDictionary removeObjectForKey:question.question_id];
    }
    if (0 < wrapperDictionary.count) {
        [self addToCoreData:wrapperDictionary.allValues];
    }
}

- (void)handleNewQuestions:(NSArray*)newQuestions
{
    if (newQuestions) {
        if (0==newQuestions.count) {
            [self callFetchReturnedNoDataDelegate];
        } else {
            [self synchronizeCoreDataQuestionsWithJsonArray:newQuestions];
            [self callDataChangedInBackgroundWhenInBackground];
        }
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
    [self handleNewQuestions:receivedData[@"new"]];
    
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
