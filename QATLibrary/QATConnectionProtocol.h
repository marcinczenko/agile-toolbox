//
//  QATConnectionProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATConnectionDelegateProtocol.h"

@protocol QATConnectionProtocol <NSObject>

@property (nonatomic, copy) NSURLRequest *urlRequest;

- (void)start;
- (void)startPOSTWithBody:(NSData*)body;
- (void) setDelegate:(id<QATConnectionDelegateProtocol>)delegate;
- (NSString*)urlString;

@end
