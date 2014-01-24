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
- (void)controllerDidChangeContent;
- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fetchReturnedNoData;
- (void)fetchReturnedNoDataInBackground;
- (void)dataChangedInBackground;
- (void)connectionFailure;
- (void)connectionFailureInBackground;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSections;

@end
