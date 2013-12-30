//
//  EPConnection.m
//  EPConnection
//
//  Created by Marcin Czenko on 7/4/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import "EPConnection.h"
#import "EPConnectionDelegateProtocol.h"

@interface EPConnection ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, assign) NSInteger contentLength;

@property (nonatomic, assign) float previousMilestone;

@property (nonatomic, copy) EPConnectionProgressBlock progressBlock;
@property (nonatomic, copy) EPConnectionCompletionBlock completionBlock;

// OCMock has problem with "weak" properties:
// http://stackoverflow.com/questions/9104544/how-can-i-get-ocmock-under-arc-to-stop-nilling-an-nsproxy-subclass-set-using-a-w
// It should be fine to use assign for the remaining delegate properties.
@property (nonatomic, weak) id<EPConnectionDelegateProtocol> connectionDelegate;

@end

@implementation EPConnection

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

+ (id)createWithURL:(NSURL*)url
{
    return [[self alloc] initWithURL:url];
}

+ (id)createWithURL:(NSURL *)url
      progressBlock:(EPConnectionProgressBlock) progress
    completionBlock:(EPConnectionCompletionBlock) completion;
{
    return [[self alloc] initWithURL:url progressBlock:progress completionBlock:completion];
}

- (id)init
{
    return [self initWithURLRequest:nil];
}

- (id)initWithURL:(NSURL *)url
{
    return [self initWithURL:url progressBlock:nil completionBlock:nil];
}

- (id)initWithURL:(NSURL *)url
    progressBlock:(EPConnectionProgressBlock) progress
  completionBlock:(EPConnectionCompletionBlock) completion;
{
    return [self initWithURLRequest:[NSURLRequest requestWithURL:url] progressBlock:progress completionBlock:completion];
}

- (id)initWithURLRequest:(NSURLRequest*)urlRequest
{
    return [self initWithURLRequest:urlRequest progressBlock:nil completionBlock:nil];
}

- (id)initWithURLRequest:(NSURLRequest*)urlRequest
           progressBlock:(EPConnectionProgressBlock) progress
         completionBlock:(EPConnectionCompletionBlock) completion
{
    if ((self = [super init])) {
        _url = [[urlRequest URL] copy];
        _urlRequest = [urlRequest copy];
        self.progressBlock = progress;
        self.completionBlock = completion;
        self.progressThreshold = 1;
    }
    return self;
}

- (void)setUrlRequest:(NSURLRequest *)urlRequest
{
    _urlRequest = [urlRequest copy];
    _url = [urlRequest.URL copy];
}

- (void)start
{
    [self createConnection];
}

- (void)getAsynchronousWithParams:(NSDictionary*)params
{
    if (0<params.count) {
        
        __block NSString *url_with_params = [_url.absoluteString stringByAppendingString:@"?"];
        __block BOOL isFirstParam = YES;
        
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *format = (isFirstParam) ? @"%@=%@" : @"&%@=%@";
            url_with_params = [url_with_params stringByAppendingFormat:format,key,obj];
            isFirstParam = NO;
        }];
        
        self.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url_with_params]];
    }
    
    [self createConnection];
}

- (BOOL)isValidPOSTRequest
{
    if ([_urlRequest isKindOfClass:[NSMutableURLRequest class]] &&
        [_urlRequest.HTTPMethod isEqualToString:@"POST"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startPOSTWithBody:(NSData *)body
{
    if ([self isValidPOSTRequest]) {
        [(NSMutableURLRequest*)_urlRequest setHTTPBody:body];
        [self start];
    }
}

- (void)setDelegate:(id<EPConnectionDelegateProtocol>)delegate
{
    self.connectionDelegate = delegate;
}

- (NSString*) urlString
{
    return self.url.absoluteString;
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
//        NSLog(@"Response Status:%u",[httpResponse statusCode]);
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