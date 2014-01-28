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
#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"
#import "EPDependencyBox.h"


@interface EPQuestionsTableViewController : UITableViewController<UIScrollViewDelegate,
                                                                  NSFetchedResultsControllerDelegate,
                                                                  EPQuestionsDataSourceDelegateProtocol,
                                                                  EPAddQuestionDelegateProtocol,
                                                                  EPPostmanDelegateProtocol>

- (void)injectDependenciesFrom:(EPDependencyBox*)dependencyBox;


@property (nonatomic,readonly) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,readonly) id<EPPostmanProtocol> postman;

@property (nonatomic,readonly) EPQuestionsTableViewControllerStateMachine *stateMachine;
@property (nonatomic,readonly) EPQuestionsTableViewExpert *tableViewExpert;

@property (nonatomic,readonly) EPQuestionsTableViewControllerStatePreservationAssistant* statePreservationAssistant;

- (void)didEnterBackgroundNotification:(NSNotification*)paramNotification;
- (void)willEnterForegroundNotification:(NSNotification*)paramNotification;
- (void)didBecomeActiveNotification:(NSNotification*)paramNotification;

@end
