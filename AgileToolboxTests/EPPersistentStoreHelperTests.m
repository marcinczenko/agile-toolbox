//
//  EPPersistentStore.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 28/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPPersistentStoreHelper.h"

@interface EPPersistentStoreHelperTests : XCTestCase

@end

@implementation EPPersistentStoreHelperTests

- (NSURL*)persistantStateFileURL
{
    NSFileManager* fileManager = [NSFileManager new];
    return [[fileManager URLForDirectory:NSApplicationSupportDirectory
                                inDomain:NSUserDomainMask
                       appropriateForURL:nil
                                  create:NO
                                   error:nil] URLByAppendingPathComponent:@"TestData.xml"];
}

- (void)removeStatePreservationFileIfExists
{
    NSURL* questionsDataSourceFileURL = [self persistantStateFileURL];
    NSFileManager* fileManager = [NSFileManager new];
    if([fileManager fileExistsAtPath:[questionsDataSourceFileURL path]]) {
        [fileManager removeItemAtURL:questionsDataSourceFileURL error:nil];
    }
}


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatPersistentStoreCanStoreADictionaryToAFile
{
    [self removeStatePreservationFileIfExists];
    
    NSDictionary* testDictionary = @{@"Key1": @YES,
                                     @"Key2": @123,
                                     @"Key3": @"String"};
    
    [EPPersistentStoreHelper storeDictionary:testDictionary toFile:@"TestData.xml"];
    
    XCTAssertEqualObjects(testDictionary,[EPPersistentStoreHelper readDictionaryFromFile:@"TestData.xml"]);
}

@end
