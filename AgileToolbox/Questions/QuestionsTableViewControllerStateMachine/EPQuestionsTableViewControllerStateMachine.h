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
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;

- (void)willResignActiveNotification:(NSNotification*)notification;
- (void)didEnterBackgroundNotification:(NSNotification*)notification;
- (void)willEnterForegroundNotification:(NSNotification*)notification;
- (void)didBecomeActiveNotification:(NSNotification*)notification;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue;


- (void)setStateObject:(id)stateObject forStateName:(NSString*)name;

@end
