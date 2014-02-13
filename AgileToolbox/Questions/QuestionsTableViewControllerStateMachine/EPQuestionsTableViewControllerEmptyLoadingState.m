//
//  EPQuestionsTableViewControllerEmptyLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerEmptyConnectionFailureState.h"
#import "EPQuestionsDataSourceProtocol.h"

@implementation EPQuestionsTableViewControllerEmptyLoadingState

- (void)viewWillDisappear
{
    self.viewController.fetchedResultsController.delegate = nil;
    self.viewController.statePreservationAssistant.viewNeedsRefreshing = YES;
    self.viewController.questionsDataSource.backgroundFetchMode = YES;
    
    [super viewWillDisappear];
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    self.viewController.fetchedResultsController.delegate = nil;
    self.viewController.statePreservationAssistant.viewNeedsRefreshing = YES;
    self.viewController.questionsDataSource.backgroundFetchMode = YES;
    
    [super didEnterBackgroundNotification:notification];
}

- (void)controllerDidChangeContent
{
    self.viewController.tableView.estimatedRowHeight = 105.0;
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
        [self.tableViewExpert deleteFetchMoreCell];
    }
    [self.tableViewExpert.tableView endUpdates];
    [self.viewController setupRefreshControl];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [EPQuestionsTableViewExpert fetchMoreRowHeight];
}


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                                                     forIndexPath:indexPath
                                                                                          loading:YES];
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

- (void)fetchReturnedNoData
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)fetchReturnedNoDataInBackground
{
    NSLog(@"fetchReturnedNoDataInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)dataChangedInBackground
{
    [self.viewController setupRefreshControl];
    self.viewController.tableView.estimatedRowHeight = 105.0;
    NSLog(@"dataChangedInBackground");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert removeTableFooter];
    
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
    }
}

- (void)connectionFailure
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)connectionFailureInBackground
{
    NSLog(@"connectionFailureInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return 0;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}


@end
