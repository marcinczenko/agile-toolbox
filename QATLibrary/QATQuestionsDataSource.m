//
//  QATQuestionsDataSource.m
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATQuestionsDataSource.h"
#import "QATDataSourceDelegateProtocol.h"

@interface QATQuestionsDataSource ()

@property (nonatomic,strong) id<QATConnectionProtocol> connection;
@property (nonatomic,strong) NSArray* json_object;
// TODO: change to weak - we keep assign because OCMock has problem with weak delegates.
// See: http://stackoverflow.com/questions/9104544/how-can-i-get-ocmock-under-arc-to-stop-nilling-an-nsproxy-subclass-set-using-a-w
@property (nonatomic,assign) id<QATDataSourceDelegateProtocol> dataSourceDelegate;

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

- (void)setDelegate:(id<QATDataSourceDelegateProtocol>)delegate
{
    self.dataSourceDelegate = delegate;
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
    
    if ([self.dataSourceDelegate respondsToSelector:@selector(dataSoruceLoaded)]) {
        [self.dataSourceDelegate dataSoruceLoaded];
    }
}

@end
