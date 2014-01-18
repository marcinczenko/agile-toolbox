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

+ (id)instance
{
    static EPQuestionsTableViewControllerEmptyLoadingState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerEmptyLoadingState alloc] init];
    }
    return instance;
}

- (void)viewDidLoad:(EPQuestionsTableViewController*)viewController
{
    [viewController.questionsDataSource fetchOlderThan:-1];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)controllerDidChangeContent:(EPQuestionsTableViewController*)viewController
{
    if (!viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        viewController.state = [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState instance];
        [viewController deleteFetchMoreCell];
        [viewController.tableView endUpdates];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        viewController.state = [EPQuestionsTableViewControllerQuestionsWithFetchMoreState instance];
        [viewController.tableView endUpdates];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[viewController setFetchIndicatorsStatusTo:NO];
    }
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1==indexPath.section) {
        EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:viewController.tableView forIndexPath:indexPath];
        fetchMoreCell.label.hidden = YES;
        [fetchMoreCell.activityIndicator startAnimating];
        
        [self addTableFooterViewInOrderToHideEmptyCellsIn:viewController];
        
        return fetchMoreCell;
    } else {
        return nil;
    }
}

- (void)fetchReturnedNoData:(EPQuestionsTableViewController*)viewController
{
    viewController.state = [EPQuestionsTableViewControllerEmptyNoQuestionsState instance];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [viewController.tableView beginUpdates];
    [viewController deleteFetchMoreCell];
    [viewController.tableView setTableFooterView:nil];
    [viewController.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [viewController.tableView endUpdates];
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return 0;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSectionsInTableView:(EPQuestionsTableViewController*)viewController
{
    return 2;
}


@end
