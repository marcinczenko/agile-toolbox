//
//  EPConnectionTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/3/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPConnection.h"
#import "EPConnectionDelegateProtocol.h"
#import "EPJSONPostURLRequest.h"

typedef void(^CallbackBlock)(NSData*);

// OCMock has problem with "weak" properties:
// http://stackoverflow.com/questions/9104544/how-can-i-get-ocmock-under-arc-to-stop-nilling-an-nsproxy-subclass-set-using-a-w
@interface EPConnectionDelegateStub : NSObject<EPConnectionDelegateProtocol>

- (id)initWithBlock:(CallbackBlock)callback;
- (void)downloadCompleted:(NSData *)data;

@property (nonatomic,copy) CallbackBlock callback;

@end

@implementation EPConnectionDelegateStub
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

@interface EPConnectionTests : XCTestCase

@property (nonatomic,readonly) NSInteger StatusCode_OK;
@property (nonatomic,readonly) NSURLConnection* connectionDoesNotMatter;

@property (nonatomic,readonly) NSURL* exampleURL;
@property (nonatomic,readonly) NSData* examplePOSTHTTPBody;
@property (nonatomic,strong) EPConnection * connection;

@property (nonatomic,assign) BOOL startStubCalled;


- (NSData*) generateTestData;
- (NSHTTPURLResponse*) createHTTPResponseWithContentLength:(NSInteger) contentLength;

@end

@implementation EPConnectionTests

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
    NSString * bodyString = @"Example HTTP Body";
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSHTTPURLResponse*) createHTTPResponseWithContentLength:(NSInteger) contentLength
{
    return [[NSHTTPURLResponse alloc] initWithURL:self.exampleURL 
                                       statusCode:self.StatusCode_OK
                                      HTTPVersion:@"HTTP/1.1" 
                                     headerFields:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%li",(long)contentLength], @"Content-Length", nil]];
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
    self.connection = [EPConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:nil];
}

- (NSData*) generateTestData
{
    Byte data_array[100];
    
    return [NSData dataWithBytes:&data_array length:100];
}

- (void)testCreatingAConnectionObjectWithURLUsingClassMethod
{
    EPConnection * connection = [EPConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:nil];
    
    XCTAssertNotNil(connection, @"Connection object is Nil!");
    
    XCTAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString);
    XCTAssertEqualObjects(connection.urlRequest.URL, self.exampleURL);
    XCTAssertEqual(connection.progressThreshold, (NSUInteger)1);
}

- (void)testCreatingAConnectionObjectUsingExternalURLRequestObject
{
    EPConnection* connection = [[EPConnection alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.exampleURL]];
    
    XCTAssertNotNil(connection, @"Connection object is Nil!");
    
    XCTAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString);
    XCTAssertEqualObjects(connection.urlRequest.URL, self.exampleURL);
    XCTAssertEqual(connection.progressThreshold, (NSUInteger)1);
}

- (void)testCreatingAConnectionWithoutURLRequestAndSettingItLater
{
    EPConnection* connection = [[EPConnection alloc] init];
    
    XCTAssertNotNil(connection, @"Connection object is Nil!");
    
    XCTAssertNil(connection.url,@"connection.url should be nil");
    XCTAssertNil(connection.urlRequest,@"connection.urlRequest should be nil");
    XCTAssertEqual(connection.progressThreshold, (NSUInteger)1,@"connection.progressThreshold should be 1");
    
    connection.urlRequest = [NSURLRequest requestWithURL:self.exampleURL];
    
    XCTAssertNotNil(connection.url,@"After setting urlRequest, connection.url should no longer be nil");
    XCTAssertNotNil(connection.urlRequest,@"After setting the urlRequest, connection.urlRequest should no longer be nil.");
    XCTAssertEqualObjects(connection.url.absoluteString, self.exampleURL.absoluteString);
    XCTAssertEqualObjects(connection.urlRequest.URL, self.exampleURL);
    XCTAssertEqual(connection.progressThreshold, (NSUInteger)1,@"After setting the urlRequest, connection.progressThreshold should still be 1");
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
    
    EPConnection* connection = [[EPConnection alloc] initWithURLRequest:postRequest];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[partialConnectionMock expect] start];
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    XCTAssertEqualObjects([[NSString alloc] initWithData:connection.urlRequest.HTTPBody encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:self.examplePOSTHTTPBody encoding:NSUTF8StringEncoding]);
    
    [partialConnectionMock verify];
    
}

- (void)testThatStartingPOSTConnectionSilentlyFailsIfURLRequestIsNotMutable
{
    EPConnection* connection = [[EPConnection alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.exampleURL]];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[[partialConnectionMock stub] andCall:@selector(startStub) onObject:self] start];
    
    self.startStubCalled = NO;
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    XCTAssertNil(connection.urlRequest.HTTPBody);
    XCTAssertFalse(self.startStubCalled);
        
    [partialConnectionMock verify];
}

- (void)testThatStartingPOSTConnectionSilentlyFailsIfURLRequestDoesNotHavePOSTAsHTTPMethod
{
    EPConnection* connection = [[EPConnection alloc] initWithURLRequest:[NSMutableURLRequest requestWithURL:self.exampleURL]];
    
    id partialConnectionMock = [OCMockObject partialMockForObject:connection];
    [[[partialConnectionMock stub] andCall:@selector(startStub) onObject:self] start];
    
    self.startStubCalled = NO;
    
    [connection startPOSTWithBody:self.examplePOSTHTTPBody];
    
    XCTAssertNil(connection.urlRequest.HTTPBody);
    XCTAssertFalse(self.startStubCalled);
    
    [partialConnectionMock verify];
}

- (void)testDelegateReceivedResponse
{
    NSInteger content_length = 100;

    XCTAssertNil(self.connection.downloadData,@"Connection object should be nil at this point");
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:content_length]];
    
    XCTAssertEqual(self.connection.contentLength,content_length,@"The length in the response is not the same as the intended content length!");
    XCTAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");
    XCTAssertEqual(self.connection.downloadData.length, (NSUInteger)0, @"The length of the downloaded data shuld be 0!");
}

- (void)testDelegateDidReceivedData
{
    NSData * test_data = [self generateTestData];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];
    
    XCTAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data];
    
    XCTAssertEqual(self.connection.contentLength, (NSInteger)test_data.length,@"Content length should equal the length of the test_data!");
    XCTAssertEqualObjects(self.connection.downloadData,test_data,@"downloaded data and test data should have the same content!");
    
}

- (void)testIncreamentalReceptionOfData
{
    NSData * test_data = [self generateTestData];

    NSData * test_data_increment_0 = [test_data subdataWithRange:NSMakeRange(0, test_data.length/2)];
    NSData * test_data_increment_1 = [test_data subdataWithRange:NSMakeRange(test_data.length/2, test_data.length - test_data.length/2)];

    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];

    XCTAssertNotNil(self.connection.downloadData,@"Downloaded data should be initiailized at this point!");

    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_0];
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_1];

    
    XCTAssertEqual(self.connection.contentLength, (NSInteger)test_data.length,@"Content length should equal the length of the test_data!");
    XCTAssertEqualObjects(self.connection.downloadData,test_data,@"downloaded data and test data should have the same content!");
}

- (void)testIfCompletionBlockIsCalledAfterDataHasBeenReceived
{
    __block BOOL blockHasBeenCalled = NO;
    
    EPConnectionCompletionBlock completion_block = ^(EPConnection *connection, NSError *error) {
        blockHasBeenCalled = YES;
        XCTAssertEqual(connection, self.connection,@"Received connection pointer is just so wrong.");
        XCTAssertEqualObjects(error,nil,@"error should be nil if no error!");
    };
    
    self.connection = [EPConnection createWithURL:self.exampleURL progressBlock:nil completionBlock:completion_block];
    
    XCTAssertFalse(blockHasBeenCalled,@"Completion block should not have been called at this point yet!");
    
    [self.connection connectionDidFinishLoading:self.connectionDoesNotMatter];
    
    XCTAssertTrue(blockHasBeenCalled,@"Completion block should have been called by that time!");
}

- (void)testIfProgressBlockIsCalledAsDataIsBeingReceived
{
    __block int numberOfTimesCalled = 0;
    
    EPConnectionProgressBlock progress_block = ^(EPConnection *connection) {
        XCTAssertEqual(connection, self.connection,@"Received connection pointer is just so wrong.");
        numberOfTimesCalled++;
    };
    
    self.connection = [EPConnection createWithURL:self.exampleURL progressBlock:progress_block completionBlock:nil];
    
    XCTAssertEqual(numberOfTimesCalled,0);
    
    NSData * test_data = [self generateTestData];
    
    NSData * test_data_increment_0 = [test_data subdataWithRange:NSMakeRange(0, test_data.length/2)];
    NSData * test_data_increment_1 = [test_data subdataWithRange:NSMakeRange(test_data.length/2, test_data.length - test_data.length/2)];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:test_data.length]];
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_0];
    [self.connection connection:self.connectionDoesNotMatter didReceiveData:test_data_increment_1];
    
    XCTAssertEqual(2,numberOfTimesCalled,@"Pregress Block Should have been called twice!");
}

- (void)testChangingProgressReportingResolution
{
    __block int numberOfTimesCalled = 0;
    
    EPConnectionProgressBlock progress_block = ^(EPConnection *connection) {
        XCTAssertEqual(connection, self.connection,@"Received connection pointer is just so wrong.");
        numberOfTimesCalled++;
    };
    
    NSInteger content_length = 100;
    
    self.connection = [EPConnection createWithURL:self.exampleURL progressBlock:progress_block completionBlock:nil];
    
    self.connection.progressThreshold = 2;
    
    [self.connection connection:self.connectionDoesNotMatter didReceiveResponse:[self createHTTPResponseWithContentLength:content_length]];
    
    [self sendDataIncrementally:content_length];
    
    XCTAssertEqual(self.connection.contentLength, content_length,@"Content length should equal the length of the test_data!");
    XCTAssertEqual(self.connection.downloadData.length, (NSUInteger)content_length,@"The length of the dowloaded data should equal the length of the test_data!");
    XCTAssertEqual(50,numberOfTimesCalled,@"Pregress Block Should have been called after every data block!");
}

- (void)testSettingTheDelegate
{
    NSData * test_data = [self generateTestData];
    __block BOOL delegateOK = NO;
    
    EPConnectionDelegateStub* delegateStub = [[EPConnectionDelegateStub alloc] initWithBlock:^(NSData * data) {
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
    
    XCTAssertTrue(delegateOK,@"Delgate was not called or with unexpected argument contents!");
}

@end
