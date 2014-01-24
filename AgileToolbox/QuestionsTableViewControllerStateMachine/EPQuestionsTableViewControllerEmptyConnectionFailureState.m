//
//  EPQuestionsTableViewControllerEmptyConnectionFailureState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyConnectionFailureState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"

@implementation EPQuestionsTableViewControllerEmptyConnectionFailureState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView forIndexPath:indexPath loading:NO];
    
    fetchMoreCell.label.text = @"Connection failure. Pull up to try again.";
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewExpert scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:scrollView]) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
        [self.viewController.questionsDataSource fetchOlderThan:-1];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
    }
}

@end
