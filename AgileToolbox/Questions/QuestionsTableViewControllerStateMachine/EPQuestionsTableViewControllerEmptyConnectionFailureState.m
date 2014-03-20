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

@end
