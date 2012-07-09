//
//  QATQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

#import "QATQuestionsTableViewController.h"
#import "QATDataSourceProtocol.h"

#import "QATQuestionsSmartTableViewCell.h"


@interface QATQuestionsTableViewControllerTests : SenTestCase

@end


@implementation QATQuestionsTableViewControllerTests

- (id)doesNotMatter
{
    return nil;
}

- (void)testQATQuestionTableViewControllerHasPropertyForDataSource
{
    QATQuestionsTableViewController* vc = [[QATQuestionsTableViewController alloc] init];
    
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    
    vc.questionsDataSource = dataSourceMock;
}

- (void)testViewControllerTriggersLoadingDataAtDataSource
{
    QATQuestionsTableViewController* vc = [[QATQuestionsTableViewController alloc] init];
    
    id dataSourceMock = [OCMockObject mockForProtocol:@protocol(QATDataSourceProtocol)];
    [[dataSourceMock expect] downloadData];
    [[dataSourceMock expect] downloadData];
    
    vc.questionsDataSource = dataSourceMock;
    
    [vc viewDidLoad];
    
    [dataSourceMock verify];
}

- (void)testThatTheCellForTheQACellIsSetupCorrectly
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    id tableViewCellMock = [OCMockObject mockForClass:[UITableViewCell class]];
    
    [[[tableViewMock stub] andReturn:tableViewCellMock] dequeueReusableCellWithIdentifier:NSStringFromClass([QATQuestionsSmartTableViewCell class])];
    
    id textLabelMock = [OCMockObject mockForClass:[UILabel class]];
    
    [[textLabelMock expect] setText:@"Questions"];
    [[[textLabelMock stub] andReturn:@"Questions"] text];
    
    [[[tableViewCellMock stub] andReturn:textLabelMock] textLabel];
    [[tableViewCellMock expect] setAccessibilityLabel:@"Questions"];
    
    QATQuestionsTableViewController* vc = [[QATQuestionsTableViewController alloc] init];
    
    [vc tableView:tableViewMock cellForRowAtIndexPath:self.doesNotMatter];
    
    [textLabelMock verify];
    [tableViewCellMock verify];
    [tableViewMock verify];
}


@end
