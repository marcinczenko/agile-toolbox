//
//  EPQuestionsTableViewControllerStateMachine.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>

#import "EPQuestionsTableViewExpert.h"

@class EPQuestionsTableViewController;
@class EPQuestionsTableViewControllerState;

@interface EPQuestionsTableViewControllerStateMachine : NSObject

@property (nonatomic,readonly) EPQuestionsTableViewControllerState *currentState;
@property (nonatomic,readonly) EPQuestionsTableViewController *viewController;
@property (nonatomic,readonly) EPQuestionsTableViewExpert *tableViewExpert;


- (void)assignViewController:(EPQuestionsTableViewController*)viewController andTableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert;

- (void)changeCurrentStateTo:(Class)stateClass;

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


- (void)setStateObject:(id)stateObject forStateName:(NSString*)name;

@end
