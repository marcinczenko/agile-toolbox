//
//  EPQuestionsTableViewControllerQuestionsLoadinRefreshingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingRefreshingState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@implementation EPQuestionsTableViewControllerQuestionsLoadingRefreshingState

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
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
        [self.tableViewExpert deleteFetchMoreCell];
    }
    [self.tableViewExpert.tableView endUpdates];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.viewController.questionsRefreshControl endRefreshing];
}

- (void)dataChangedInBackground
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.viewController.questionsRefreshControl endRefreshing];
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
    }
    [self checkAndCancelRestoringScrollPosition];
}

- (void)fetchReturnedNoData
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.viewController.questionsRefreshControl endRefreshing];
    [self.tableViewExpert.tableView beginUpdates];
    [self.tableViewExpert deleteFetchMoreCell];
    [self.tableViewExpert.tableView endUpdates];
}

- (void)fetchReturnedNoDataInBackground
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.viewController.questionsRefreshControl endRefreshing];
    [self checkAndCancelRestoringScrollPosition];
}


@end
