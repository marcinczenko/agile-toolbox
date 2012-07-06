//
//  QATSmartTableViewCellTest.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATSmartTableViewCell.h"

@interface QATSmartTableViewCellTest : SenTestCase

@end

@implementation QATSmartTableViewCellTest

- (void)testCreatingQATSmartTableViewCellWithReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATSmartTableViewCell class])];
    
    
    QATSmartTableViewCell* smart_cell = [QATSmartTableViewCell cellForTableView:tableViewMock];
    
    STAssertEqualObjects(smart_cell, tableViewCellMock,nil);
}

- (void)testCreatingQATSmartTableViewCellWithoutReusableCell
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([QATSmartTableViewCell class])];
    
    // this is the only thing we can really test here
    STAssertNotNil([QATSmartTableViewCell cellForTableView:tableViewMock],nil);
}

- (void)testGettingCellIdentifierBasedOnTheClassName
{
    STAssertEqualObjects([QATSmartTableViewCell cellIdentifier],NSStringFromClass([QATSmartTableViewCell class]),nil);
}

@end
