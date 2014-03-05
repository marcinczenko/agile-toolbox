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
#import "EPAddQuestionTableViewController.h"


#import "EPPersistentStoreHelper.h"

@interface EPQuestionsTableViewControllerState ()

@property (nonatomic,weak) EPQuestionsTableViewControllerStateMachine *stateMachine;

@end

@implementation EPQuestionsTableViewControllerState

+ (NSInteger)tagSnapshot
{
    return 1900;
}

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

- (void)setTableViewBackgroundColor
{
    if (0<=self.viewController.statePreservationAssistant.bounds.origin.y) {
        self.tableViewExpert.tableView.backgroundColor = [UIColor whiteColor];
    } else {
        self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    }
}

- (void)viewWillAppear
{
    if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
        [self.viewController relinkToFetchedResultsController];
    }
    
    if (self.viewController.statePreservationAssistant.snapshot.isImageFresh) {
        
        [self setTableViewBackgroundColor];
        
        [self.viewController.statePreservationAssistant.snapshot displayInView:self.tableViewExpert.tableView withTag:[self.class tagSnapshot] originComputationBlock:^CGPoint{
            // Q: contentSize or better contentInset?
            // A: contentSize is set when bounds are set even though contentInset is still not set
            //    when bounds are non-zero it is save to position the contents
            // Notice: isViewLoaded is set to 1 regardless, so it is useless in this case
            //         view.window is nill in both cases.
            // Notice: if viewDidLoad has been called then self.tableView.contentSize.height
            //         is not ready yet == table view is freshly loaded and its bounds will still change
            if (0==self.tableViewExpert.tableView.contentSize.height) {
                return CGPointMake(0, 0);
            } else {
                return CGPointMake(0, self.tableViewExpert.tableView.bounds.origin.y + self.tableViewExpert.tableView.contentInset.top);
            }
        }];
    }
}

- (void)viewDidAppear
{
    if (!self.tableViewExpert.refreshControl) {
        self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    }
    
    if (self.viewController.statePreservationAssistant.snapshot.isImageFresh) {
        
        [self.viewController.statePreservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.viewController];
        
        CGRect correctedBounds = self.viewController.tableView.bounds;
        correctedBounds.origin.y += self.viewController.statePreservationAssistant.scrollDelta;

        self.tableViewExpert.tableView.bounds = correctedBounds;
        
        [self.viewController.statePreservationAssistant.snapshot removeViewWithTag:[self.class tagSnapshot] fromSuperview:self.tableViewExpert.tableView];
        self.tableViewExpert.tableView.userInteractionEnabled = YES;
    }
}

- (void)viewWillDisappear
{
    self.viewController.statePreservationAssistant.bounds = self.viewController.tableView.bounds;
    
    if ([self.tableViewExpert scrolledToTopOrHigher] && !self.viewController.refreshControl.isRefreshing) {
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
            
            [self.viewController relinkToFetchedResultsController];
        }
    }
}

- (void)didBecomeActiveNotification:(NSNotification*)notification
{
    
}

- (void)controllerWillChangeContent
{    
    [self.tableViewExpert.tableView beginUpdates];
}

- (void)controllerDidChangeQuestion:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"This should never happen");
            [self.tableViewExpert.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                                  withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[indexPath]
                                                  withRowAnimation:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}


- (void)controllerDidChangeContent
{
    [self.tableViewExpert.tableView endUpdates];
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
        EPAddQuestionTableViewController* addQuestionViewController = (EPAddQuestionTableViewController*)segue.destinationViewController;
        
        addQuestionViewController.statePreservationAssistant = self.viewController.statePreservationAssistant;
        addQuestionViewController.questionsDataSource = self.viewController.questionsDataSource;
        addQuestionViewController.postman = self.viewController.postman;
        
    } else if ([segue.identifier isEqualToString:@"QuestionDetails"]) {
        EPQuestionDetailsTableViewController* questionDetailsViewController = (EPQuestionDetailsTableViewController*)segue.destinationViewController;
        
        questionDetailsViewController.question = [self questionObjectForIndexPath:[self.tableViewExpert.tableView indexPathForSelectedRow]];
    }
}

@end
