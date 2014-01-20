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

//@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) id<EPConnectionProtocol> connection;
@property (nonatomic,strong) NSMutableArray* json_object;
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> dataSourceDelegate;
//@property (nonatomic,assign) NSUInteger currentPageNumber;
//@property (nonatomic,readonly) NSUInteger nextPageIndex;
@property (nonatomic,assign) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,weak) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic,strong) NSManagedObjectContext* backgroundObjectContext;

@end

@implementation EPQuestionsDataSource

@synthesize connection = _connection;
@synthesize json_object = _json_object;

const NSUInteger QUESTIONS_PER_PAGE = 40;
const NSUInteger NEXT_PAGE_INDEX_TRESHOLD = 20;

//- (NSUInteger) length
//{
//    return self.fetchedResultsController.fetchedObjects.count;
//    //return self.json_object.count;
//}

- (NSString*) connectionURL
{
    return [self.connection urlString];
}

- (id)initWithConnection:(id<EPConnectionProtocol>)connection andWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    self = [super init];
    
    if (self) {
        self.connection = connection;
        self.persistentStoreCoordinator = persistentStoreCoordinator;
        [self.connection setDelegate:self];
        self.hasMoreQuestionsToFetch = YES;
        EPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.backgroundObjectContext = appDelegate.managedObjectContext;
    }
    return self;
}

+ (NSUInteger)pageSize
{
    return QUESTIONS_PER_PAGE;
}

- (void)setPostConnection:(id<EPConnectionProtocol>)connection
{
    
}

//- (NSString*)getOldestQuestionId
//{
//    return ((Question*)self.fetchedResultsController.fetchedObjects.lastObject).question_id;
//    //return [self.json_object.lastObject objectForKey:@"id"];
//}

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

//- (NSString*)questionAtIndex:(NSUInteger)index
//{
//    Question *question = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//    return question.content;
//    //return [[self.json_object objectAtIndex:index] objectForKey:@"content"];
//}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"controllerWillChangeContent");
//    if ([self.dataSourceDelegate respondsToSelector:@selector(dataSourceWillUpdate)]) {
//        [self.dataSourceDelegate dataSourceWillUpdate];
//    }
//}

//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    if (type == NSFetchedResultsChangeInsert) {
//        NSLog(@"didChangeObject:%@ at index[row]=%ld and index[section]=%ld",((Question*)anObject).content,newIndexPath.row,newIndexPath.section);
//        if ([self.dataSourceDelegate respondsToSelector:@selector(dataSourceInsertedObject:atIndex:)]) {
//            [self.dataSourceDelegate dataSourceInsertedObject:anObject atIndex:newIndexPath.row];
//        }
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"controllerDidChangeContent");
//    if ([self.dataSourceDelegate respondsToSelector:@selector(dataSourceDidUpdate)]) {
//        [self.dataSourceDelegate dataSourceDidUpdate];
//    }
//}

- (void)addToManagedObjectContextFromDictionary:(NSDictionary *)questionDictionaryObject
{
    Question *newQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.backgroundObjectContext];
    
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
    
    if ([self.backgroundObjectContext save:&savingError]) {
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
