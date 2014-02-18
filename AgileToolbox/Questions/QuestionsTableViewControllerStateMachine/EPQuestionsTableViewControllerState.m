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

#import "EPPersistentStoreHelper.h"

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

- (void)viewDidLoad
{
    
}

- (void)relinkToFetchedResultsController
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

- (void)viewWillAppear
{
    if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
        [self relinkToFetchedResultsController];
    }
    
    if (self.viewController.statePreservationAssistant.snapshotView) {
        if (0<=self.viewController.statePreservationAssistant.bounds.origin.y) {
            self.tableViewExpert.tableView.backgroundColor = [UIColor whiteColor];
        } else {
            self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
        }
        
        // Q: contentSize or better contentInset?
        // A: contentSize is set when bounds are set even though contentInset is still not set
        //    when bounds are non-zero it is save to position the contents
        // Notice: isViewLoaded is set to 1 regardless, so it is useless in this case
        //         view.window is nill in both cases.
        if (0==self.tableViewExpert.tableView.contentSize.height) {
            NSLog(@"AAAAAAAAA");
            // view dimensions are not yet calculated - we operate in a simplified frame
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            if (self.viewController.refreshControl.isRefreshing) {
                NSLog(@"BBBBBBBB");
                frame.origin = CGPointMake(0, -self.viewController.refreshControl.frame.size.height);
            } else {
                NSLog(@"CCCCCCCCC");
                frame.origin = CGPointMake(0, 0);
            }
            
            self.viewController.statePreservationAssistant.snapshotView.frame = frame;
        } else {
            NSLog(@"DDDDDDDDDD");
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            if (self.viewController.refreshControl.isRefreshing) {
                NSLog(@"EEEEEEEEEE");
                frame.origin = CGPointMake(0, self.viewController.tableView.bounds.origin.y+self.viewController.tableView.contentInset.top-self.viewController.refreshControl.frame.size.height);
            } else {
                NSLog(@"FFFFFFFFFF");
                frame.origin = CGPointMake(0, self.viewController.tableView.bounds.origin.y+self.viewController.tableView.contentInset.top);
            }
            
            self.viewController.statePreservationAssistant.snapshotView.frame = frame;
        }
        
        [self.tableViewExpert.tableView addSubview:self.viewController.statePreservationAssistant.snapshotView];
    }
}

- (void)viewDidAppear
{
    if (!self.tableViewExpert.refreshControl) {
        self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    }
    
    if (self.viewController.statePreservationAssistant.snapshotView) {
        
        [self.viewController.statePreservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.viewController];
        
        CGRect correctedBounds = self.viewController.tableView.bounds;
        correctedBounds.origin.y += self.viewController.statePreservationAssistant.scrollDelta;

        self.tableViewExpert.tableView.bounds = correctedBounds;
        
        self.viewController.statePreservationAssistant.snapshotView.hidden = YES;
        [self.viewController.statePreservationAssistant.snapshotView removeFromSuperview];
        self.viewController.statePreservationAssistant.snapshotView = nil;
    }
}

- (void)viewWillDisappear
{
    self.viewController.statePreservationAssistant.bounds = self.viewController.tableView.bounds;
    
    if (-64.0>=self.tableViewExpert.tableView.bounds.origin.y && !self.viewController.refreshControl.isRefreshing) {
        return ;
    }
    
    if (self.viewController.hasQuestionsInPersistentStorage) {
        [self.viewController.statePreservationAssistant recordCurrentStateForViewController:self.viewController];
    }
}

- (void)willResignActiveNotification:(NSNotification*)notification
{
    self.viewController.statePreservationAssistant.bounds = self.viewController.tableView.bounds;
    
    if (-64.0>=self.tableViewExpert.tableView.bounds.origin.y && !self.viewController.refreshControl.isRefreshing) {
        return ;
    }
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
            
            [self relinkToFetchedResultsController];
        }
    }
}

- (void)didBecomeActiveNotification:(NSNotification*)notification
{
    
}

- (void)controllerWillChangeContent
{
    [self.tableViewExpert removeTableFooter];
    [self.tableViewExpert.tableView beginUpdates];
}

- (void)controllerDidChangeQuestion:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    [self.tableViewExpert.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"AddQuestion"]) {
        
        UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
        
        EPAddQuestionViewController* destinationVC =  (EPAddQuestionViewController*)navigationController.topViewController;
        destinationVC.delegate = self.viewController;
    } else if ([segue.identifier isEqualToString:@"QuestionDetails"]) {
        EPQuestionDetailsTableViewController* questionDetailsViewController = (EPQuestionDetailsTableViewController*)segue.destinationViewController;
        
        questionDetailsViewController.question = [self questionObjectForIndexPath:[self.tableViewExpert.tableView indexPathForSelectedRow]];
    }
}

@end
