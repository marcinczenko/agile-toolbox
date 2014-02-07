//
//  EPQuestionsTableViewControllerState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsTableViewControllerStateMachine.h"

@interface EPQuestionsTableViewControllerState ()

@property (nonatomic,weak) EPQuestionsTableViewControllerStateMachine *stateMachine;

@end

@implementation EPQuestionsTableViewControllerState

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController
             tableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
             andStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    if ((self = [super init])) {
        _viewController = viewController;
        _tableViewExpert = tableViewExpert;
        _stateMachine = stateMachine;
    }
    
    return self;
}

- (id)initWithStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    return [self initWithViewController:nil tableViewExpert:nil andStateMachine:stateMachine];
}

- (void)enterForeground
{
    self.viewController.statePreservationAssistant.viewNeedsRefreshing = NO;
    self.viewController.questionsDataSource.backgroundFetchMode = NO;
    self.viewController.fetchedResultsController.delegate = self.viewController;
    [self refetchFromCoreData];
}

- (void)refetchFromCoreData
{
    NSError *fetchError = nil;
    [self.viewController.fetchedResultsController performFetch:&fetchError];
}

- (void)viewDidLoad
{
    if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
        [self enterForeground];
    }
}

- (void)viewWillAppear
{
    if (self.viewController.statePreservationAssistant.snapshotView) {
        if (0<=self.viewController.statePreservationAssistant.contentOffset.y) {
            self.tableViewExpert.tableView.backgroundColor = [UIColor whiteColor];
        } else {
            self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
        }
        
        [self.tableViewExpert.tableView addSubview:self.viewController.statePreservationAssistant.snapshotView];
    }
}

- (void)viewDidAppear
{
    self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    
    if (self.viewController.statePreservationAssistant.snapshotView) {
        [self.viewController.statePreservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.viewController];
        self.viewController.statePreservationAssistant.snapshotView.hidden = YES;
        [self.viewController.statePreservationAssistant.snapshotView removeFromSuperview];
        self.viewController.statePreservationAssistant.snapshotView = nil;
    }
}

- (void)viewWillDisappear
{
    if (self.viewController.hasQuestionsInPersistentStorage) {
        [self.viewController.statePreservationAssistant recordCurrentStateForViewController:self.viewController];
    }
}

- (void)willResignActiveNotification:(NSNotification*)notification
{
    if (self.viewController.viewIsVisible && self.viewController.hasQuestionsInPersistentStorage) {
        [self.viewController.statePreservationAssistant recordCurrentStateForViewController:self.viewController];
    }
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    [self.viewController.statePreservationAssistant storeToPersistentStorage];
    [self.viewController.questionsDataSource storeToPersistentStorage];
}

- (void)willEnterForegroundNotification:(NSNotification*)notification
{
    if ([self.viewController viewIsVisible]) {
        if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
            NSLog(@"questionsTableViewController:BLOCK: UIApplicationWillEnterForegroundNotification");
            
            [self enterForeground];
            
            [self.tableViewExpert.tableView reloadData];
        }
    }
}

- (void)didBecomeActiveNotification:(NSNotification*)notification
{
    
}

- (void)controllerDidChangeContent
{
    
}

- (void)fetchReturnedNoData
{
    
}

- (void)fetchReturnedNoDataInBackground
{
    
}

- (void)dataChangedInBackground
{
    
}

- (void)connectionFailure
{
    
}

- (void)connectionFailureInBackground
{
    
}


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (void)refresh
{
    
}

@end
