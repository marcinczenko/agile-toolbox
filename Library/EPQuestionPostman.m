//
//  EPQuestionPostman.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPQuestionPostman.h"
#import "EPJSONPostURLRequest.h"

@interface EPQuestionPostman ()

@property (nonatomic,strong) id<EPConnectionProtocol> connection;

- (NSData*)createJSONRequestBodyFor:(NSString*)item;

@end

@implementation EPQuestionPostman
@synthesize connection = _connection;
@synthesize delegate = _delegate;

- (id)initWithConnection:(id<EPConnectionProtocol>)connection
{
    if ((self = [super init])) {
        _connection = connection;
        [_connection setDelegate:self];
    }
    return self;
}

- (NSData*)createJSONRequestBodyFor:(NSString*)item
{
    NSArray* json_object = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:item forKey:@"content"]];
    return [NSJSONSerialization dataWithJSONObject:json_object options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)post:(NSString *)item
{
    [_connection startPOSTWithBody:[self createJSONRequestBodyFor:item]];
}

#pragma mark - EPConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data
{
    NSString *serverResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([serverResponse isEqualToString:@"ADDED"]) {
        if ([self.delegate respondsToSelector:@selector(postDelivered)]) {
            [self.delegate postDelivered];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(postDeliveryFailed)]) {
            [self.delegate postDeliveryFailed];
        }
    }
}

@end
