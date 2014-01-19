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

@property (nonatomic,readonly,weak) EPQuestionsTableViewController *viewController;
@property (nonatomic,readonly,weak) EPQuestionsTableViewExpert *tableViewExpert;
@property (nonatomic,readonly,weak) EPQuestionsTableViewControllerStateMachine *stateMachine;

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController
          tableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
             andStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine;

- (void)viewDidLoad;
- (void)controllerDidChangeContent;
- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fetchReturnedNoData;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSections;

@end
