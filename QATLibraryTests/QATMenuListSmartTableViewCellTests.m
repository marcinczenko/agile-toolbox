//
//  QATMenuListTableViewCellTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATMenuListSmartTableViewCell.h"

@interface QATMenuListSmartTableViewCellTests : XCTestCase

@end

@implementation QATMenuListSmartTableViewCellTests

- (void)testThatTableCellIsCreatedWithRightCellIdentifierIsReturned
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATMenuListSmartTableViewCell class])];
    
    XCTAssertEqualObjects([QATMenuListSmartTableViewCell cellForTableView:tableViewMock], tableViewCellMock );
}

- (void)testThatTableCellIsCreatedWithAppropriateReuseIdentifier
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([QATMenuListSmartTableViewCell class])];
    
    QATMenuListSmartTableViewCell* smartCell = [QATMenuListSmartTableViewCell cellForTableView:tableViewMock];
    
    XCTAssertNotNil(smartCell);
    XCTAssertEqualObjects(smartCell.reuseIdentifier, [QATMenuListSmartTableViewCell cellIdentifier]);
}

@end
