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

- (void)viewWillDisappear
{
    
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView forIndexPath:indexPath loading:NO];
    
    [fetchMoreCell setCellText:EPFetchMoreTableViewCellTextConnectionFailurePullUpToTryAgain];
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ([self.tableViewExpert scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:scrollView]) {
//        self.viewController.isScrolling = NO;
//        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
//        [self.viewController.questionsDataSource fetchOlderThan:-1];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//        [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
//    }
//}

@end
