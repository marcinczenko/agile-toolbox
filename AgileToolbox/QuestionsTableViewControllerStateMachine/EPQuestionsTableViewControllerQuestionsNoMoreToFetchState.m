//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
        [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    }
    return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                 forIndexPath:indexPath
                                                  andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return self.viewController.fetchedResultsController.fetchedObjects.count;
}


@end
