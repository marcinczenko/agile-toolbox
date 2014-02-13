//
//  EPQuestionsTableViewControllerQuestionsLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsConnectionFailureState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsLoadingState

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (0==indexPath.section) {
        return [EPQuestionsTableViewExpert questionRowHeight];
    } else {
        return [EPQuestionsTableViewExpert fetchMoreRowHeight];
    }
}

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

- (void)fetchReturnedNoDataInBackground
{
    NSLog(@"fetchReturnedNoDataInBackground");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
}

- (void)connectionFailure
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)connectionFailureInBackground
{
    NSLog(@"connectionFailureInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.viewController.numberOfQuestionsInPersistentStorage;
    } else {
        return 1 ;
    }
}

@end
