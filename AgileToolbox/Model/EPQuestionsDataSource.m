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
    }
    return self;
}

- (void)setPostConnection:(id<EPConnectionProtocol>)connection
{
    
}

- (void)fetchOlderThan:(NSInteger)questionId
{
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
        if ([self.delegate respondsToSelector:@selector(fetchReturnedNoData)]) {
            [self.delegate fetchReturnedNoData];
        }
    } else {
        [self saveToCoreData:new_data];
    }
}

@end
