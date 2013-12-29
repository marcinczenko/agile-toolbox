//
//  EPPostURLRequest.m
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPJSONPostURLRequest.h"

@implementation EPJSONPostURLRequest

- (id)initWithURL:(NSURL *)URL
{
    return [self initWithURL:URL body:nil];
}

- (id)initWithURL:(NSURL *)URL body:(NSData *)bodyData
{
    if ((self = [super initWithURL:URL])) {
        [self setHTTPMethod:@"POST"];
        [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self setHTTPBody:bodyData];
    }
    return self;
}

@end

