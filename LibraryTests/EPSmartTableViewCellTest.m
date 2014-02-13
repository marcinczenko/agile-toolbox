//
//  EPSmartTableViewCellTest.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPSmartTableViewCell.h"

@interface EPSmartTableViewCellTest : XCTestCase

@end

@implementation EPSmartTableViewCellTest

- (void)testCreatingQATSmartTableViewCellWithReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([EPSmartTableViewCell class])];
    
    
    EPSmartTableViewCell* smart_cell = [EPSmartTableViewCell cellForTableView:tableViewMock];
    
    XCTAssertEqualObjects(smart_cell, tableViewCellMock);
}

- (void)testCreatingQATSmartTableViewCellWithoutReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([EPSmartTableViewCell class])];
    
    EPSmartTableViewCell* smartCell = [EPSmartTableViewCell cellForTableView:tableViewMock];
    
    // this is the only thing we can really test here
    XCTAssertNotNil(smartCell);
    XCTAssertEqualObjects(smartCell.reuseIdentifier, [EPSmartTableViewCell cellIdentifier]);
}

- (void)testGettingCellIdentifierBasedOnTheClassName
{
    XCTAssertEqualObjects([EPSmartTableViewCell cellIdentifier],NSStringFromClass([EPSmartTableViewCell class]));
}

@end
