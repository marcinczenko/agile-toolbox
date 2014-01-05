//
//  EPQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPQuestionsDataSource.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface EPQuestionsDataSource ()

@property (nonatomic,strong) id<EPConnectionProtocol> connection;
@property (nonatomic,strong) NSMutableArray* json_object;
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> dataSourceDelegate;
@property (nonatomic,assign) NSUInteger currentPageNumber;
@property (nonatomic,readonly) NSUInteger nextPageIndex;
@property (nonatomic,assign) BOOL hasMoreQuestionsToFetch;

@end

@implementation EPQuestionsDataSource

@synthesize connection = _connection;
@synthesize json_object = _json_object;
@synthesize dataSourceDelegate = _dataSourceDelegate;

const NSUInteger QUESTIONS_PER_PAGE = 40;
const NSUInteger NEXT_PAGE_INDEX_TRESHOLD = 20;

- (NSUInteger) length
{
    return self.json_object.count;
}

- (NSString*) connectionURL
{
    return [self.connection urlString];
}

- (id)initWithConnection:(id<EPConnectionProtocol>)connection
{
    self = [super init];
    
    if (self) {
        _connection = connection;
        [_connection setDelegate:self];
        _json_object = [NSMutableArray array];
        _hasMoreQuestionsToFetch = YES;
    }
    return self;
}

- (void)setDelegate:(id<EPQuestionsDataSourceDelegateProtocol>)delegate
{
    self.dataSourceDelegate = delegate;
}

+ (NSUInteger)pageSize
{
    return QUESTIONS_PER_PAGE;
}

- (NSUInteger)nextPageIndex
{
    return self.currentPageNumber*self.questionsPerPage-self.nextPageIndexTreshold;
}

- (NSUInteger)questionsPerPage
{
    return QUESTIONS_PER_PAGE;
}

- (NSUInteger)nextPageIndexTreshold
{
    return NEXT_PAGE_INDEX_TRESHOLD;
}

- (void)setPostConnection:(id<EPConnectionProtocol>)connection
{
    
}

- (NSString*)getOldestQuestionId
{
    return [self.json_object.lastObject objectForKey:@"id"];
}

- (void)fetch
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"n": [NSString stringWithFormat:@"%lu",
                                                                                         (unsigned long)QUESTIONS_PER_PAGE]}];
    
    if ([self getOldestQuestionId]) {
        [params addEntriesFromDictionary:@{@"id": [self getOldestQuestionId]}];
    }
    
    [self.connection getAsynchronousWithParams:params];
}

- (void)fetchNew
{
    
}

- (NSString*)questionAtIndex:(NSUInteger)index
{
    return [[self.json_object objectAtIndex:index] objectForKey:@"content"];
}

- (void)downloadCompleted:(NSData *)data
{
    NSArray *new_data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSInteger fromIndex = self.json_object.count;
    NSInteger toIndex = fromIndex+new_data.count-1;
    
    if (QUESTIONS_PER_PAGE > new_data.count) {
        _hasMoreQuestionsToFetch = NO;
    }
    
    [self.json_object addObjectsFromArray:new_data];
    
    if ([self.dataSourceDelegate respondsToSelector:@selector(questionsFetchedFromIndex:to:)]) {
        [self.dataSourceDelegate questionsFetchedFromIndex:fromIndex to:toIndex];
    }
}

@end
