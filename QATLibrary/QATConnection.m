//
//  QATConnection.m
//  QATConnection
//
//  Created by Marcin Czenko on 7/4/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import "QATConnection.h"
#import "QATConnectionDelegateProtocol.h"

@interface QATConnection ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, assign) NSInteger contentLength;

@property (nonatomic, assign) float previousMilestone;

@property (nonatomic, copy) QATConnectionProgressBlock progressBlock;
@property (nonatomic, copy) QATConnectionCompletionBlock completionBlock;

// OCMock has problem with "weak" properties:
// http://stackoverflow.com/questions/9104544/how-can-i-get-ocmock-under-arc-to-stop-nilling-an-nsproxy-subclass-set-using-a-w
// It should be fine to use assign for the remaining delegate properties.
@property (nonatomic, weak) id<QATConnectionDelegateProtocol> connectionDelegate;

@end

@implementation QATConnection

@synthesize connection = _connection;
@synthesize url = _url;
@synthesize urlRequest = _urlRequest;
@synthesize contentLength = _contentLength;
@synthesize downloadData = _downloadData;
@synthesize progressThreshold = _progressThreshold;

@synthesize previousMilestone = _previousMilestone;
@synthesize progressBlock = _progressBlock;
@synthesize completionBlock = _completionBlock;

@synthesize connectionDelegate = _connectionDelegate;

+ (id)createWithURL:(NSURL *)url
      progressBlock:(QATConnectionProgressBlock) progress
    completionBlock:(QATConnectionCompletionBlock) completion;
{
    return [[self alloc] initWithURL:url progressBlock:progress completionBlock:completion];
}

- (id)initWithURL:(NSURL *)url
    progressBlock:(QATConnectionProgressBlock) progress
  completionBlock:(QATConnectionCompletionBlock) completion;
{
    if ((self = [super init])) {
        _url = [url copy];
        _urlRequest = [NSURLRequest requestWithURL:url];
        self.progressBlock = progress;
        self.completionBlock = completion;
        self.progressThreshold = 1.0;
    }
    return self;
}

- (void)start
{
    [self createConnection];
}

- (void)setDelegate:(id<QATConnectionDelegateProtocol>)delegate
{
    self.connectionDelegate = delegate;
}

- (void)createConnection
{
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
}

- (float)percentComplete
{
    if (self.contentLength <= 0) return 0;
    return (([self.downloadData length] * 1.0f) / self.contentLength) * 100;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection 
    didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] == 200) {
            NSDictionary *header = [httpResponse allHeaderFields];
            NSString *contentLen = [header valueForKey:@"Content-Length"];
            NSInteger length = self.contentLength = [contentLen integerValue];
            self.downloadData = [NSMutableData dataWithCapacity:length];
        }
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.downloadData appendData:data];
    float percentComplete = floor([self percentComplete]);
    if ((percentComplete - self.previousMilestone) >= self.progressThreshold) {
        self.previousMilestone = percentComplete;
        if (self.progressBlock) self.progressBlock(self);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed");
    if (self.completionBlock) self.completionBlock(self, error);
    self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.connectionDelegate respondsToSelector:@selector(downloadCompleted:)]) {
        [self.connectionDelegate downloadCompleted:self.downloadData];
    }
    if (self.completionBlock) self.completionBlock(self, nil);
    self.connection = nil;
}

@end