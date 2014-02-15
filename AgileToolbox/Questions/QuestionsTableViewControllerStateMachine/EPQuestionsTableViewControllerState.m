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

#import "EPQuestionDetailsTableViewController.h"
#import "EPAddQuestionViewController.h"

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
    [self.tableViewExpert.tableView reloadData];
}

- (void)refetchFromCoreData
{
    NSError *fetchError = nil;
    [self.viewController.fetchedResultsController performFetch:&fetchError];
}

- (void)viewDidLoad
{
    
}

- (void)viewWillAppear
{
    if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
        [self enterForeground];
    }
    
    if (self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration) {
        return;
    }
    
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
    
    if (self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration) {
        self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration = NO;
        self.viewController.statePreservationAssistant.snapshotView = nil;
        return;
    }
    
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

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [EPQuestionsTableViewExpert questionRowHeight];
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

- (void)refresh:(UIRefreshControl*)refreshControl
{
    
}

- (Question*) questionObjectForIndexPath:(NSIndexPath*)indexPath
{
    return [self.viewController.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)skipRefreshing
{
    self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"AddQuestion"]) {
        
        UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
        
        EPAddQuestionViewController* destinationVC =  (EPAddQuestionViewController*)navigationController.topViewController;
        destinationVC.delegate = self.viewController;
    } else if ([segue.identifier isEqualToString:@"QuestionDetails"]) {
        EPQuestionDetailsTableViewController* questionDetailsViewController = (EPQuestionDetailsTableViewController*)segue.destinationViewController;
        
        questionDetailsViewController.question = [self questionObjectForIndexPath:[self.tableViewExpert.tableView indexPathForSelectedRow]];
        
        [self skipRefreshing];
    }
}

@end
