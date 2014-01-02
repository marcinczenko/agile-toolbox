//
//  EPConnection.h
//  EPConnection
//
//  Created by Marcin Czenko on 7/4/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPConnectionProtocol.h"

@class EPConnection;

typedef void (^EPConnectionProgressBlock)(EPConnection *connection);
typedef void (^EPConnectionCompletionBlock)(EPConnection *connection, NSError *error);

@interface EPConnection : NSObject <EPConnectionProtocol,NSURLConnectionDataDelegate>

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy) NSURLRequest *urlRequest;
@property (nonatomic, assign, readonly) NSInteger contentLength;
@property (nonatomic, strong, readonly) NSMutableData *downloadData;
@property (readonly) float percentComplete;
@property (nonatomic, assign) NSUInteger progressThreshold;

+ (id)createWithURL:(NSURL*)url;
+ (id)createWithURL:(NSURL*)url
      progressBlock:(EPConnectionProgressBlock) progress
    completionBlock:(EPConnectionCompletionBlock) completion;

- (id)init;
- (id)initWithURL:(NSURL*)url;
- (id)initWithURL:(NSURL*)url
    progressBlock:(EPConnectionProgressBlock) progress
  completionBlock:(EPConnectionCompletionBlock) completion;

- (id)initWithURLRequest:(NSURLRequest*)urlRequest;
- (id)initWithURLRequest:(NSURLRequest*)urlRequest
    progressBlock:(EPConnectionProgressBlock) progress
  completionBlock:(EPConnectionCompletionBlock) completion;


- (void)start;
- (void)getAsynchronousWithParams:(NSDictionary*)params;
- (void)setDelegate:(id<EPConnectionDelegateProtocol>)delegate;
- (void)createConnectionWithURLRequest:(NSURLRequest*)urlRequest;

@end
