//
//  QATQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATQuestionsDataSource.h"

@interface QATQuestionsDataSource ()

@property (nonatomic,strong) id<QATConnectionProtocol> connection;
@property (nonatomic,strong) NSArray* json_object;

@end

@implementation QATQuestionsDataSource

@synthesize connection = _connection;
@synthesize json_object = _json_object;

- (NSInteger) length
{
    return self.json_object.count;
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

- (void)loadData
{
    [self.connection start];
}

- (NSString*)questionAtIndex:(NSUInteger)index
{
    return [[self.json_object objectAtIndex:index] objectForKey:@"contents"];
}

- (void)downloadCompleted:(NSData *)data
{
    self.json_object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end
