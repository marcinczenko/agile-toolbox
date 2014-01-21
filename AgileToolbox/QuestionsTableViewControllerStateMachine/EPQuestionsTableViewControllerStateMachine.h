//
//  EPQuestionsTableViewControllerStateMachine.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>

#import "EPQuestionsTableViewControllerStateMachineDelegateProtocol.h"
#import "EPQuestionsTableViewExpert.h"

@class EPQuestionsTableViewController;
@class EPQuestionsTableViewControllerState;

@interface EPQuestionsTableViewControllerStateMachine : NSObject

@property (nonatomic,readonly) EPQuestionsTableViewControllerState *currentState;
@property (nonatomic,readonly) EPQuestionsTableViewController *viewController;
@property (nonatomic,readonly) EPQuestionsTableViewExpert *tableViewExpert;


- (id)initWithViewController:(EPQuestionsTableViewController*)viewController andTableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert;


- (void)startStateMachine;
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
