//
//  EPConnectionProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPConnectionDelegateProtocol.h"

@protocol EPConnectionProtocol <NSObject>

@property (nonatomic, copy) NSURLRequest *urlRequest;

- (void)start;
- (void)startPOSTWithBody:(NSData*)body;
- (void) setDelegate:(id<EPConnectionDelegateProtocol>)delegate;
- (NSString*)urlString;

@end
