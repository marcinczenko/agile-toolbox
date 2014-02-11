//
//  EPQuestionsTableViewControllerState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPQuestionsTableViewController.h"
#import "EPQuestionsTableViewExpert.h"
#import "EPQuestionsTableViewControllerStateMachine.h"

@interface EPQuestionsTableViewControllerState : NSObject

@property (nonatomic,weak) EPQuestionsTableViewController *viewController;
@property (nonatomic,weak) EPQuestionsTableViewExpert *tableViewExpert;
@property (nonatomic,readonly) EPQuestionsTableViewControllerStateMachine *stateMachine;

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController
          tableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
             andStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine;

- (id)initWithStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine;

- (void)viewDidLoad;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;

- (void)willResignActiveNotification:(NSNotification*)notification;
- (void)didEnterBackgroundNotification:(NSNotification*)notification;
- (void)willEnterForegroundNotification:(NSNotification*)notification;
- (void)didBecomeActiveNotification:(NSNotification*)notification;

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSections;

- (void)controllerDidChangeContent;
- (void)fetchReturnedNoData;
- (void)fetchReturnedNoDataInBackground;
- (void)dataChangedInBackground;
- (void)connectionFailure;
- (void)connectionFailureInBackground;

- (void)refresh:(UIRefreshControl*)refreshControl;

@end
