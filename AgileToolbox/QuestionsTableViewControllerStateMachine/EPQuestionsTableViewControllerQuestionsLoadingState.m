//
//  EPQuestionsTableViewControllerQuestionsLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsLoadingState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                     forIndexPath:indexPath
                                                      andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        return [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                      forIndexPath:indexPath
                                                           loading:YES];
    }
}

- (void)fetchReturnedNoData
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView beginUpdates];
    [self.tableViewExpert deleteFetchMoreCell];
    [self.tableViewExpert.tableView endUpdates];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.viewController.fetchedResultsController.fetchedObjects.count;
    } else {
        return 1 ;
    }
}

@end
