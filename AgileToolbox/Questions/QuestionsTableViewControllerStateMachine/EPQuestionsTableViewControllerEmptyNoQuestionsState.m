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

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView forIndexPath:indexPath loading:NO];
    
    fetchMoreCell.label.text = @"No questions on the server";
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

@end
