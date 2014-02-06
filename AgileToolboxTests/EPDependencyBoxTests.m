//
//  EPDependencyBoxTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPDependencyBox.h"

@interface EPDependencyBoxTests : XCTestCase

@property (nonatomic,strong) EPDependencyBox* dependencyBox;

@end

@implementation EPDependencyBoxTests

- (void)setUp
{
    [super setUp];
    
    self.dependencyBox = [[EPDependencyBox alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCreatingDependencyBox
{
    EPDependencyBox* dependencyBox = [[EPDependencyBox alloc] init];
    
    XCTAssertNotNil(dependencyBox);
}

- (void)testDependencyBoxHasNoDependenciesAfterCreation
{
    XCTAssertFalse([self.dependencyBox hasDependencies]);
}

- (void)testAddingDependency
{
    NSString* testDependencyName = @"TestDependencyName";
    NSObject* aDependency = [NSObject new];
    
    self.dependencyBox[testDependencyName] = aDependency;
    
    XCTAssertTrue([self.dependencyBox hasDependencies]);
    XCTAssertEqualObjects(aDependency, self.dependencyBox[testDependencyName]);
}

- (void)testRemovingDependency
{
    NSString* testDependencyName = @"TestDependencyName";
    NSObject* aDependency = [NSObject new];
    
    self.dependencyBox[testDependencyName] = aDependency;
    
    XCTAssertTrue([self.dependencyBox hasDependencies]);
    XCTAssertEqualObjects(aDependency, self.dependencyBox[testDependencyName]);
    
    [self.dependencyBox removeDependencyForName:testDependencyName];
    XCTAssertFalse([self.dependencyBox hasDependencies]);
    XCTAssertEqualObjects(nil, self.dependencyBox[testDependencyName]);
    
}

@end
