//
//  QATSmartTableViewCellTest.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "QATSmartTableViewCell.h"

@interface QATSmartTableViewCellTest : XCTestCase

@end

@implementation QATSmartTableViewCellTest

- (void)testCreatingQATSmartTableViewCellWithReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATSmartTableViewCell class])];
    
    
    QATSmartTableViewCell* smart_cell = [QATSmartTableViewCell cellForTableView:tableViewMock];
    
    XCTAssertEqualObjects(smart_cell, tableViewCellMock);
}

- (void)testCreatingQATSmartTableViewCellWithoutReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([QATSmartTableViewCell class])];
    
    QATSmartTableViewCell* smartCell = [QATSmartTableViewCell cellForTableView:tableViewMock];
    
    // this is the only thing we can really test here
    XCTAssertNotNil(smartCell);
    XCTAssertEqualObjects(smartCell.reuseIdentifier, [QATSmartTableViewCell cellIdentifier]);
}

- (void)testGettingCellIdentifierBasedOnTheClassName
{
    XCTAssertEqualObjects([QATSmartTableViewCell cellIdentifier],NSStringFromClass([QATSmartTableViewCell class]));
}

@end
