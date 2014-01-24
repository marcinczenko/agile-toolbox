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
#import "EPQuestionsTableViewControllerEmptyConnectionFailureState.h"

@implementation EPQuestionsTableViewControllerEmptyLoadingState


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
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableViewExpert removeTableFooter];
//    
//    [self.tableViewExpert.tableView beginUpdates];
//    [self.tableViewExpert deleteFetchMoreCell];
//    [self.tableViewExpert.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
//                          withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableViewExpert.tableView endUpdates];
}

- (void)fetchReturnedNoDataInBackground
{
    NSLog(@"fetchReturnedNoDataInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //[self.tableViewExpert removeTableFooter];
}

- (void)dataChangedInBackground
{
    NSLog(@"dataChangedInBackground");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert removeTableFooter];
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
    }
}

- (void)connectionFailure
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)connectionFailureInBackground
{
    NSLog(@"connectionFailureInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
