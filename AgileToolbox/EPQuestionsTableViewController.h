//
//  EPQuestionsTableViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPAddQuestionDelegateProtocol.h"

#import "EPPostmanProtocol.h"
#import "EPPostmanDelegateProtocol.h"

#import "EPFetchMoreTableViewCell.h"

@class EPQuestionsTableViewControllerState;


@interface EPQuestionsTableViewController : UITableViewController<UIScrollViewDelegate,
                                                                  NSFetchedResultsControllerDelegate,
                                                                  EPQuestionsDataSourceDelegateProtocol,
                                                                  EPAddQuestionDelegateProtocol,
                                                                  EPPostmanDelegateProtocol>

@property (nonatomic,weak) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) id<EPPostmanProtocol> postman;
@property (nonatomic,weak) EPQuestionsTableViewControllerState *state;

@property (nonatomic,readonly) CGFloat contentHeight;



- (UITableViewCell*)setUpQuestionCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;
//- (void)addTableFooterViewInOrderToHideEmptyCells;
- (BOOL) totalContentHeightSmallerThanScreenSize;

//
// Do not call these methods directly - they are made public only for the purpose of testing.
//
//- (void)setFetchIndicatorsStatusTo:(BOOL)status;
- (void)deleteFetchMoreCell;

@end
