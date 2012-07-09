//
//  QATMenuListTableViewCellTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/6/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATMenuListSmartTableViewCell.h"

@interface QATMenuListSmartTableViewCellTests : SenTestCase

@end

@implementation QATMenuListSmartTableViewCellTests

- (void)testThatTableCellIsCreatedWithRightCellIdentifierIsReturned
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATMenuListSmartTableViewCell class])];
    
    STAssertEqualObjects([QATMenuListSmartTableViewCell cellForTableView:tableViewMock], tableViewCellMock ,nil);
}

- (void)testThatTableCellIsCreatedWithAppropriateReuseIdentifier
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    
    [[[tableViewMock stub] andReturn:nil] dequeueReusableCellWithIdentifier:NSStringFromClass([QATMenuListSmartTableViewCell class])];
    
    QATMenuListSmartTableViewCell* smartCell = [QATMenuListSmartTableViewCell cellForTableView:tableViewMock];
    
    STAssertNotNil(smartCell,nil);
    STAssertEqualObjects(smartCell.reuseIdentifier, [QATMenuListSmartTableViewCell cellIdentifier],nil);
}

@end
