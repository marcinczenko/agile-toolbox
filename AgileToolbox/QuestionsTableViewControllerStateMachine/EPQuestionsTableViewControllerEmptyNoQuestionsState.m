//
//  EPQuestionsTableViewControllerEmptyNoQuestionsState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@implementation EPQuestionsTableViewControllerEmptyNoQuestionsState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView forIndexPath:indexPath loading:NO];
    
    fetchMoreCell.label.text = @"No questions on the server";
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

//- (NSInteger)numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}

@end
