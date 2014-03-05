//
//  EPQuestionsTableViewControllerEmptyNoQuestionsState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@implementation EPQuestionsTableViewControllerEmptyNoQuestionsState

- (void)viewWillDisappear
{
    
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [EPQuestionsTableViewExpert fetchMoreRowHeight];
}


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView forIndexPath:indexPath loading:NO];
    
    fetchMoreCell.label.text = @"No questions on the server. Pull down to refresh.";
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewExpert scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:scrollView]) {
        self.viewController.isScrolling = NO;
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
        [self.viewController.questionsDataSource fetchOlderThan:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
    }
}

@end
