//
//  QATQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATQuestionsDataSource.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface QATQuestionsDataSource ()

@property (nonatomic,strong) id<QATConnectionProtocol> connection;
@property (nonatomic,strong) NSArray* json_object;
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> dataSourceDelegate;

@end

@implementation QATQuestionsDataSource

@synthesize connection = _connection;
@synthesize json_object = _json_object;
@synthesize dataSourceDelegate = _dataSourceDelegate;

- (NSInteger) length
{
    return self.json_object.count;
}

- (NSString*) connectionURL
{
    return [self.connection urlString];
}

- (id)initWithConnection:(id<QATConnectionProtocol>)connection
{
    self = [super init];
    
    if (self) {
        _connection = connection;
        [_connection setDelegate:self];
    }
    return self;
}

- (void)setDelegate:(id<EPQuestionsDataSourceDelegateProtocol>)delegate
{
    self.dataSourceDelegate = delegate;
}

- (void)setPostConnection:(id<QATConnectionProtocol>)connection
{
    
}

- (void)fetch:(NSUInteger)numberOfQuestions
{
    
}

- (void)downloadData
{
    [self.connection start];
}

- (NSString*)questionAtIndex:(NSUInteger)index
{
    return [[self.json_object objectAtIndex:index] objectForKey:@"content"];
}

- (void)downloadCompleted:(NSData *)data
{
    self.json_object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([self.dataSourceDelegate respondsToSelector:@selector(questionsFetched)]) {
        [self.dataSourceDelegate questionsFetched];
    }
}

@end
