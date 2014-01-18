//
//  EPQuestionsTableViewControllerQuestionsLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@implementation EPQuestionsTableViewControllerQuestionsLoadingState

+ (id)instance
{
    static EPQuestionsTableViewControllerQuestionsLoadingState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerQuestionsLoadingState alloc] init];
    }
    return instance;
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        return [viewController setUpQuestionCellForTableView:viewController.tableView atIndexPath:indexPath];
    } else {
        EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:viewController.tableView forIndexPath:indexPath];
        fetchMoreCell.label.hidden = YES;
        [fetchMoreCell.activityIndicator startAnimating];
        
        return fetchMoreCell;
    }
}

- (void)fetchReturnedNoData:(EPQuestionsTableViewController*)viewController
{
    viewController.state = [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState instance];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [viewController.tableView beginUpdates];
    [viewController deleteFetchMoreCell];
    [viewController.tableView endUpdates];
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return viewController.fetchedResultsController.fetchedObjects.count;
    } else {
        return 1 ;
    }
}

@end
