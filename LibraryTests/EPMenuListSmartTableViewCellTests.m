//
//  EPMenuListTableViewCellTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPMenuListSmartTableViewCell.h"

@interface EPMenuListSmartTableViewCellTests : XCTestCase

@end

@implementation EPMenuListSmartTableViewCellTests

- (void)testThatTableCellIsCreatedWithRightCellIdentifierIsReturned
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([EPMenuListSmartTableViewCell class])];
    
    XCTAssertEqualObjects([EPMenuListSmartTableViewCell cellForTableView:tableViewMock], tableViewCellMock );
}

- (void)testThatTableCellIsCreatedWithAppropriateReuseIdentifier
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([EPMenuListSmartTableViewCell class])];
    
    EPMenuListSmartTableViewCell* smartCell = [EPMenuListSmartTableViewCell cellForTableView:tableViewMock];
    
    XCTAssertNotNil(smartCell);
    XCTAssertEqualObjects(smartCell.reuseIdentifier, [EPMenuListSmartTableViewCell cellIdentifier]);
}

@end
