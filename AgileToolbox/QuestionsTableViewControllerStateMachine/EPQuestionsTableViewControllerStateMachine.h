//
//  EPQuestionsTableViewControllerStateMachine.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>

#import "EPQuestionsTableViewController.h"
#import "EPQuestionsTableViewControllerStateMachineDelegateProtocol.h"
#import "EPQuestionsTableViewExpert.h"

@class EPQuestionsTableViewControllerState;

@interface EPQuestionsTableViewControllerStateMachine : NSObject

@property (nonatomic,readonly,strong) EPQuestionsTableViewControllerState *currentState;

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController andTableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert;


- (void)start;
- (void)changeCurrentStateTo:(Class)stateClass;

- (void)viewDidLoad;
- (void)controllerDidChangeContent;
- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fetchReturnedNoData;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSections;


- (void)setStateObject:(id)stateObject forStateName:(NSString*)name;

@end
