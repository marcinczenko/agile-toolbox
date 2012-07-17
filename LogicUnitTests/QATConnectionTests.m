//
//  QATConnectionTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/3/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATConnection.h"
#import "QATConnectionDelegateProtocol.h"
#import "QATJSONPostURLRequest.h"

typedef void(^CallbackBlock)(NSData*);

// OCMock has problem with "weak" properties:
// http://stackoverflow.com/questions/9104544/how-can-i-get-ocmock-under-arc-to-stop-nilling-an-nsproxy-subclass-set-using-a-w
@interface QATConnectionDelegateStub : NSObject<QATConnectionDelegateProtocol>

- (id)initWithBlock:(CallbackBlock)callback;
- (void)downloadCompleted:(NSData *)data;

@property (nonatomic,copy) CallbackBlock callback;

@end

@implementation QATConnectionDelegateStub
@synthesize callback = _callbackBlock;

- (id)initWithBlock:(CallbackBlock)callback
{
    self = [super init];
    if (self) {
        _callbackBlock = callback;
    }
    return self;
}

- (void)downloadCompleted:(NSData *)data
{
    if (self.callback) {
        self.callback(data);
    }
//    NSLog(@"Karwasz twarz!!!!");
}

@end

@interface QATConnectionTests : SenTestCase

@property (nonatomic,readonly) NSInteger StatusCode_OK;
@property (nonatomic,readonly) NSURLConnection* connectionDoesNotMatter;

@property (nonatomic,readonly) NSURL* exampleURL;
@property (nonatomic,readonly) NSData* examplePOSTHTTPBody;
@property (nonatomic,strong) QATConnection * connection;

@property (nonatomic,assign) BOOL startStubCalled;


- (NSData*) generateTestData;
- (NSHTTPURLResponse*) createHTTPResponseWithContentLength:(NSInteger) contentLength;

@end

@implementation QATConnectionTests

@synthesize connection = _connection;
@synthesize startStubCalled = _startStubCalled;

- (void)startStub
{
    self.startStubCalled = YES;
}

- (NSInteger) StatusCode_OK
{
    return 200;
}

- (NSURLConnection*) connectionDoesNotMatter
{
    return nil;
}

- (NSURL*) exampleURL
{
    return [NSURL URLWithString:@"https://example.com"];
}

- (NSData*)examplePOSTHTTPBody
{
    NSString * bodyString = [NSString stringWithString:@"Example HTTP Body"];
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSHTTPURLResponse*) createHTTPResponseWithContentLength:(NSInteger) contentLength
{
    return [[NSHTTPURLResponse alloc] initWithURL:self.exampleURL 
                                       statusCode:self.StatusCode_OK
                                      HTTPVersion:@"HTTP/1.1" 
                                     headerFields:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",contentLength], @"Content-Length", nil]];
}

- (void)sendDataIncrementally:(NSInteger)content_length
{
    Byte one_byte_of_data;
    
    NSMutableArray* data_increments = [NSMutableArray arrayWithCapacity:content_length];
    
    for (NSUInteger i=0; i<content_length; i++) {
        [data_increments addObject:[NSData dataWithBytes:&one_byte_of_data length:sizeof(Byte)]];
    }
    
    for (NSUInteger i=0; i<content_length; i++) {
        [self.connection connection:self.connectionDoesNotMatter didReceiveData:[data_increments objectAtIndex:i]];
    }
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.connection = [QATConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:nil];
}

- (NSData*) generateTestData
{
    Byte data_array[100];
    
    return [NSData dataWithBytes:&data_array length:100];
}

- (void)testCreatingAConnectionObjectWithURLUsingClassMethod
{
    QATConnection * connection = [QATConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:nil];
    
    STAssertNotNil(connection, @"Connection object is Nil!");
    
    STAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString,nil);
    STAssertEqualObjects(connection.urlRequest.URL, self.exampleURL,nil);
    STAssertEquals(connection.progressThreshold, (NSUInteger)1,nil);
}

- (void)testCreatingAConnectionObjectUsingExternalURLRequestObject
{
    QATConnection* connection = [[QATConnection alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.exampleURL]];
    
    STAssertNotNil(connection, @"Connection object is Nil!");
    
    STAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString,nil);
    STAssertEqualObjects(connection.urlRequest.URL, self.exampleURL,nil);
    STAssertEquals(connection.progressThreshold, (NSUInteger)1,nil);
}

- (void)testCreatingAConnectionWithoutURLRequestAndSettingItLater
{
    QATConnection* connection = [[QATConnection alloc] init];
    
    STAssertNotNil(connection, @"Connection object is Nil!");
    
    STAssertNil(connection.url,@"connection.url should be nil");
    STAssertNil(connection.urlRequest,@"connection.urlRequest should be nil");
    STAssertEquals(connection.progressThreshold, (NSUInteger)1,@"connection.progressThreshold should be 1");
    
    connection.urlRequest = [NSURLRequest requestWithURL:self.exampleURL];
    
    STAssertNotNil(connection.url,@"After setting urlRequest, connection.url should no longer be nil");
    STAssertNotNil(connection.urlRequest,@"After setting the urlRequest, connection.urlRequest should no longer be nil.");
    STAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString,nil);
    STAssertEqualObjects(connection.urlRequest.URL, self.exampleURL,nil);
    STAssertEquals(connection.progressThreshold, (NSUInteger)1,@"After setting the urlRequest, connection.progressThreshold should still be 1");
}

- (void)testStartingConnection
{
    id partialConnectionMock = [OCMockObject partialMockForObject:self.connection];
    
    [[partialConnectionMock expect] createConnection];
    
    [self.connection start];

    [partialConnectionMock verify];
}

- (void)testStartingPOSTConnection
{
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:self.exampleURL];
    [postRequest setHTTPMethod:@"POST"];
    
    QATConnection* connection = [[QATConnection alloc] initWithURLRequest:postRequest];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[partialConnectionMock expect] start];
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    STAssertEqualObjects([[NSString alloc] initWithData:connection.urlRequest.HTTPBody encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:self.examplePOSTHTTPBody encoding:NSUTF8StringEncoding],nil);
    
    [partialConnectionMock verify];
    
}

- (void)testThatStartingPOSTConnectionSilentlyFailsIfURLRequestIsNotMutable
{
    QATConnection* connection = [[QATConnection alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.exampleURL]];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[[partialConnectionMock stub] andCall:@selector(startStub) onObject:self] start];
    
    self.startStubCalled = NO;
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    STAssertNil(connection.urlRequest.HTTPBody,nil);
    STAssertFalse(self.startStubCalled,nil);
        
    [partialConnectionMock verify];
}

- (void)testThatStartingPOSTConnectionSilentlyFailsIfURLRequestDoesNotHavePOSTAsHTTPMethod
{
    QATConnection* connection = [[QATConnection alloc] initWithURLRequest:[NSMutableURLRequest requestWithURL:self.exampleURL]];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[[partialConnectionMock stub] andCall:@selector(startStub) onObject:self] start];
    
    self.startStubCalled = NO;
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    STAssertNil(connection.urlRequest.HTTPBody,nil);
    STAssertFalse(self.startStubCalled,nil);
    
    [partialConnectionMock verify];
}

- (void)testDelegateReceivedResponse
{
    NSInteger content_length = 100;

    STAssertNil(self.connection.downloadData,@"Connection object should be nil at this point");
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:content_length]];
    
    STAssertEquals(self.connection.contentLength,content_length,@"The length in the response is not the same as the intended content length!");
    STAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");
    STAssertEquals(self.connection.downloadData.length, (NSUInteger)0, @"The length of the downloaded data shuld be 0!");
}

- (void)testDelegateDidReceivedData
{
    NSData * test_data = [self generateTestData];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];
    
    STAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data];
    
    STAssertEquals(self.connection.contentLength, (NSInteger)test_data.length,@"Content length should equal the length of the test_data!");
    STAssertEqualObjects(self.connection.downloadData,test_data,@"downloaded data and test data should have the same content!");
    
}

- (void)testIncreamentalReceptionOfData
{
    NSData * test_data = [self generateTestData];

    NSData * test_data_increment_0 = [test_data subdataWithRange:NSMakeRange(0, test_data.length/2)];
    NSData * test_data_increment_1 = [test_data subdataWithRange:NSMakeRange(test_data.length/2, test_data.length - test_data.length/2)];

    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];

    STAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");

    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_0];
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_1];

    
    STAssertEquals(self.connection.contentLength, (NSInteger)test_data.length,@"Content length should equal the length of the test_data!");
    STAssertEqualObjects(self.connection.downloadData,test_data,@"downloaded data and test data should have the same content!");
}

- (void)testIfCompletionBlockIsCalledAfterDataHasBeenReceived
{
    __block BOOL blockHasBeenCalled = NO;
    
    QATConnectionCompletionBlock completion_block = ^(QATConnection *connection, NSError *error) {
        blockHasBeenCalled = YES;
        STAssertEquals(connection, self.connection,@"Received connection pointer is just so wrong.");
        STAssertEqualObjects(error,nil,@"error should be nil if no error!");
    };
    
    self.connection = [QATConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:completion_block];
    
    STAssertFalse(blockHasBeenCalled,@"Completion block should not have been called at this point yet!");
    
    [self.connection connectionDidFinishLoading:self.connectionDoesNotMatter];
    
    STAssertTrue(blockHasBeenCalled,@"Completion block should have been called by that time!");
}

- (void)testIfProgressBlockIsCalledAsDataIsBeingReceived
{
    __block NSInteger numberOfTimesCalled = 0;
    
    QATConnectionProgressBlock progress_block = ^(QATConnection *connection) {
        STAssertEquals(connection, self.connection,@"Received connection pointer is just so wrong.");
        numberOfTimesCalled++;
    };
    
    self.connection = [QATConnection createWithURL:self.exampleURL progressBlock:progress_block completionBlock:nil];
    
    STAssertEquals(numberOfTimesCalled,0,nil);
    
    NSData * test_data = [self generateTestData];
    
    NSData * test_data_increment_0 = [test_data subdataWithRange:NSMakeRange(0, test_data.length/2)];
    NSData * test_data_increment_1 = [test_data subdataWithRange:NSMakeRange(test_data.length/2, test_data.length - test_data.length/2)];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_0];
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_1];
    
    STAssertEquals(2,numberOfTimesCalled,@"Pregress Block Should have been called twice!");
}

- (void)testChangingProgressReportingResolution
{
    __block NSInteger numberOfTimesCalled = 0;
    
    QATConnectionProgressBlock progress_block = ^(QATConnection *connection) {
        STAssertEquals(connection, self.connection,@"Received connection pointer is just so wrong.");
        numberOfTimesCalled++;
    };
    
    NSInteger content_length = 100;
    
    self.connection = [QATConnection createWithURL:self.exampleURL progressBlock:progress_block completionBlock:nil];
    
    self.connection.progressThreshold = 2;
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:content_length]];
    
    [self sendDataIncrementally:content_length];
    
    STAssertEquals(self.connection.contentLength, content_length,@"Content length should equal the length of the test_data!");
    STAssertEquals(self.connection.downloadData.length, (NSUInteger)content_length,@"The length of the dowloaded data should equal the length of the test_data!");
    STAssertEquals(50,numberOfTimesCalled,@"Pregress Block Should have been called after every data block!");
}

- (void)testSettingTheDelegate
{
    NSData * test_data = [self generateTestData];
    __block BOOL delegateOK = NO;
    
    QATConnectionDelegateStub* delegateStub = [[QATConnectionDelegateStub alloc] initWithBlock:^(NSData * data) {
        if ([test_data isEqualToData:data]) {
            delegateOK = YES;
        } else {
            delegateOK = NO;
        }
    }];
    
    [self.connection setDelegate:delegateStub];
    
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];    
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data];
    [self.connection connectionDidFinishLoading:self.connectionDoesNotMatter];
    
    STAssertTrue(delegateOK,@"Delgate was not called or with unexpected argument contents!");
}

@end
