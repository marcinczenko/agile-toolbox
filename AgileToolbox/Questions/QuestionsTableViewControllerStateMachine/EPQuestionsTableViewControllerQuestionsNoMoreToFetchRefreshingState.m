//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState ()

@property (nonatomic,assign) BOOL renderRefreshLoading;

@end

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState

#ifndef KEEP_VISIBLE_TIMEOUT
#define KEEP_VISIBLE_TIMEOUT 2.0
#endif

- (Question*) questionObjectForIndexPath:(NSIndexPath*)indexPath
{
    if (self.viewController.refreshControl) {
        return [self.viewController.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        NSIndexPath* adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
        return [self.viewController.fetchedResultsController objectAtIndexPath:adjustedIndexPath];
    }
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.viewController.refreshControl) {
        return [EPQuestionsTableViewExpert questionRowHeight];
    } else {
        if (0==indexPath.row) {
            return [EPQuestionsTableViewExpert fetchMoreRowHeight];
        } else {
            return [EPQuestionsTableViewExpert questionRowHeight];
        }
    }
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewController.refreshControl) {
        if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
            [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
        }
        return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                     forIndexPath:indexPath
                                                      andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        if (0==indexPath.row) {
            
            EPFetchMoreTableViewCell* cell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                                                    forIndexPath:indexPath
                                                                                         loading:YES];
            
            if (![UIApplication sharedApplication].networkActivityIndicatorVisible) {
                // We are notifying the user using dispatch_after - in connection failure.
                // Otherwise we wouldn't be in this state anymore.
                [cell setCellText:EPFetchMoreTableViewCellTextConnectionFailure];
            }
            return cell;
            
        } else {
            if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
                [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
            }
            NSIndexPath* adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
            return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                         forIndexPath:indexPath
                                                          andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:adjustedIndexPath]];
        }
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return self.viewController.numberOfQuestionsInPersistentStorage + 1;
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (void)handleEvent
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [self.viewController.refreshControl endRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)controllerDidChangeContent
{
    [self handleEvent];
    if (!self.viewController.refreshControl) {
        [self.tableViewExpert deleteRefreshingStatusCell];
    }
    [self.tableViewExpert.tableView endUpdates];
    if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
        [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    }
    [self.viewController setupRefreshControl];
}

- (void)dataChangedInBackground
{
    [self handleEvent];
}

- (void)fetchReturnedNoData
{
    [self handleEvent];
    
    if (!self.viewController.refreshControl) {
        [self.tableViewExpert removeRefreshStatusCellFromScreen];
    }
    [self.viewController setupRefreshControl];
}

- (void)fetchReturnedNoDataInBackground
{
    [self handleEvent];
}

- (void)keepVisibleFor:(double)seconds completionBlock:(void (^)())block
{
    double delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void)handleConnectionFailureUsingNativeRefreshControlCompletion
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    [self.viewController.refreshControl endRefreshing];
    if (self.viewController.viewIsVisible) {
        // the view might have dissapear in the meantime
        if (!self.viewController.refreshControl) {
            // A user could leave the questions view when refresh control was still active
            // and return when it is not anymore. The action was triggered when native
            // refresh control was active but has to be finished when it is not.
            [self.tableViewExpert removeRefreshStatusCellFromScreen];
        }
        [self.viewController setupRefreshControl];
    }
}

- (void)handleConnectionFailureUsingNativeRefreshControl
{
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:EPFetchMoreTableViewCellTextConnectionFailure];
    self.viewController.refreshControl.attributedTitle = title;
    
    [self keepVisibleFor:KEEP_VISIBLE_TIMEOUT completionBlock:^{
        [self handleConnectionFailureUsingNativeRefreshControlCompletion];
    }];
}

- (void)handleConnectionFailureUsingRefreshStatusCellCompletion
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    if (self.viewController.viewIsVisible) {
        // the view might have dissapear in the meantime
        [self.tableViewExpert removeRefreshStatusCellFromScreen];
        [self.viewController setupRefreshControl];
    }
}

- (void)handleConnectionFailureUsingRefreshStatusCell
{
    [self.tableViewExpert.refreshStatusCell setCellText:EPFetchMoreTableViewCellTextConnectionFailure];
    
    [self keepVisibleFor:KEEP_VISIBLE_TIMEOUT completionBlock:^{
        [self handleConnectionFailureUsingRefreshStatusCellCompletion];
    }];
}

- (void)connectionFailure
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.viewController.refreshControl) {
        [self handleConnectionFailureUsingNativeRefreshControl];
    } else {
        [self handleConnectionFailureUsingRefreshStatusCell];
    }
}

- (void)connectionFailureInBackground
{
    [self handleEvent];
}

//- (void)skipRefreshing
//{
//    self.viewController.statePreservationAssistant.skipRefreshing = NO;
//}



@end
