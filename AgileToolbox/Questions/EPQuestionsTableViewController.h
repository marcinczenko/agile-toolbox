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
#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionsTableViewExpert.h"


@interface EPQuestionsTableViewController : UITableViewController<UIScrollViewDelegate,
                                                                  NSFetchedResultsControllerDelegate,
                                                                  EPQuestionsDataSourceDelegateProtocol,
                                                                  EPAddQuestionDelegateProtocol,
                                                                  EPPostmanDelegateProtocol>

@property (nonatomic,weak) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) id<EPPostmanProtocol> postman;

@property (nonatomic,strong) EPQuestionsTableViewControllerStateMachine *stateMachine;
@property (nonatomic,readonly) EPQuestionsTableViewExpert *tableViewExpert;

@end
