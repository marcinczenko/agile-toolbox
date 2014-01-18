//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreState

+ (id)instance
{
    static EPQuestionsTableViewControllerQuestionsWithFetchMoreState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerQuestionsWithFetchMoreState alloc] init];
    }
    return instance;
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        if (indexPath.row == viewController.fetchedResultsController.fetchedObjects.count-1) {
            viewController.state = [EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState instance];
        }
        
        return [viewController setUpQuestionCellForTableView:viewController.tableView atIndexPath:indexPath];
    } else {
        EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:viewController.tableView forIndexPath:indexPath];
        [fetchMoreCell.activityIndicator stopAnimating];
        fetchMoreCell.label.hidden = NO;
        return fetchMoreCell;
    }
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return viewController.fetchedResultsController.fetchedObjects.count;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSectionsInTableView:(EPQuestionsTableViewController*)viewController
{
    return 2;
}


@end
