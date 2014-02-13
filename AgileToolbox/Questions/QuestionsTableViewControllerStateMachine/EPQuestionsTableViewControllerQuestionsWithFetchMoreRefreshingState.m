//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 11/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState


- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (0==indexPath.section) {
        if (self.viewController.refreshControl) {
            return [EPQuestionsTableViewExpert questionRowHeight];
        } else {
            if (0==indexPath.row) {
                return [EPQuestionsTableViewExpert fetchMoreRowHeight];
            } else {
                return [EPQuestionsTableViewExpert questionRowHeight];
            }
        }
    } else {
        return [EPQuestionsTableViewExpert fetchMoreRowHeight];
    }
}


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        if (self.viewController.refreshControl) {
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
                NSIndexPath* adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                             forIndexPath:indexPath
                                                              andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:adjustedIndexPath]];
            }
        }
        
    } else {
        EPFetchMoreTableViewCell* cell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                                                forIndexPath:indexPath
                                                                                     loading:YES];
        
        if (![UIApplication sharedApplication].networkActivityIndicatorVisible) {
            // We are notifying the user using dispatch_after - in connection failure.
            // Otherwise we wouldn't be in this state anymore.
            [cell setCellText:EPFetchMoreTableViewCellTextConnectionFailure];
        }
        return cell;
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.viewController.numberOfQuestionsInPersistentStorage + 1;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}

- (void)handleEvent
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    [self.viewController.refreshControl endRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)controllerDidChangeContent
{
    [super controllerDidChangeContent];
    [self.tableViewExpert.fetchMoreCell setLoadingStatus:NO];
}

- (void)fetchReturnedNoData
{
    [super fetchReturnedNoData];
    [self.tableViewExpert.fetchMoreCell setLoadingStatus:NO];
}

- (void)handleConnectionFailureUsingNativeRefreshControlCompletion
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    
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
        [self.tableViewExpert.fetchMoreCell setCellText:EPFetchMoreTableViewCellTextDefault];
    }
    
}

- (void)handleConnectionFailureUsingRefreshStatusCellCompletion
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    
    if (self.viewController.viewIsVisible) {
        // the view might have dissapear in the meantime
        [self.tableViewExpert removeRefreshStatusCellFromScreen];
        [self.viewController setupRefreshControl];
        [self.tableViewExpert.fetchMoreCell setCellText:EPFetchMoreTableViewCellTextDefault];
    }
}

- (void)connectionFailure
{
    [self.tableViewExpert.fetchMoreCell setCellText:EPFetchMoreTableViewCellTextConnectionFailure];
    [super connectionFailure];
}

@end
