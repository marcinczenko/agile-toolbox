//
//  EPQuestionsTableViewControllerEmptyLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@implementation EPQuestionsTableViewControllerEmptyLoadingState

- (void)viewDidLoad
{
    [self.viewController.questionsDataSource fetchOlderThan:-1];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)controllerDidChangeContent
{
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
        [self.tableViewExpert deleteFetchMoreCell];
    }
    [self.tableViewExpert.tableView endUpdates];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                                                     forIndexPath:indexPath
                                                                                          loading:YES];
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

- (void)fetchReturnedNoData
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert removeTableFooter];
    
    [self.tableViewExpert.tableView beginUpdates];
    [self.tableViewExpert deleteFetchMoreCell];
    [self.tableViewExpert.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableViewExpert.tableView endUpdates];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return 0;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}


@end
