//
//  QATConnection.h
//  QATConnection
//
//  Created by Marcin Czenko on 7/4/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATConnectionProtocol.h"

@class QATConnection;

typedef void (^QATConnectionProgressBlock)(QATConnection *connection);
typedef void (^QATConnectionCompletionBlock)(QATConnection *connection, NSError *error);

@interface QATConnection : NSObject <QATConnectionProtocol,NSURLConnectionDataDelegate>

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLRequest *urlRequest;
@property (nonatomic, assign, readonly) NSInteger contentLength;
@property (nonatomic, strong, readonly) NSMutableData *downloadData;
@property (readonly) float percentComplete;
@property (nonatomic, assign) NSUInteger progressThreshold;

+ (id)createWithURL:(NSURL*)url
      progressBlock:(QATConnectionProgressBlock) progress
    completionBlock:(QATConnectionCompletionBlock) completion;

- (id)initWithURL:(NSURL*)url
    progressBlock:(QATConnectionProgressBlock) progress
  completionBlock:(QATConnectionCompletionBlock) completion;

- (void)start;
- (void)setDelegate:(id<QATConnectionDelegateProtocol>)delegate;
- (void)createConnection;

@end
