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

@end

@implementation EPQuestionPostman

- (id)initWithConnection:(id<EPConnectionProtocol>)connection
{
    if ((self = [super init])) {
        _connection = connection;
        [_connection setDelegate:self];
    }
    return self;
}

- (NSData*)createJSONRequestBodyWithParams:(NSArray*)params
{
    return [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)post:(NSString *)item
{
    [_connection startPOSTWithBody:[self createJSONRequestBodyWithParams:@[@{@"content": item}]]];
}

- (void)postQuestionWithHeader:(NSString *)header content:(NSString *)content
{
    [_connection startPOSTWithBody:[self createJSONRequestBodyWithParams:@[@{@"header": header,
                                                                             @"content": content}]]];
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

- (void)downloadFailed
{
    if ([self.delegate respondsToSelector:@selector(postDeliveryFailed)]) {
        [self.delegate postDeliveryFailed];
    }
}

@end
