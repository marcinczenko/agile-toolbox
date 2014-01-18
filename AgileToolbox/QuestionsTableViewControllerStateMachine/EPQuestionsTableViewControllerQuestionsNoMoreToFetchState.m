//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchState

+ (id)instance
{
    static EPQuestionsTableViewControllerQuestionsNoMoreToFetchState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState alloc] init];
    }
    return instance;
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (viewController.totalContentHeightSmallerThanScreenSize) {
        [self addTableFooterViewInOrderToHideEmptyCellsIn:viewController];
    }
    return [viewController setUpQuestionCellForTableView:viewController.tableView atIndexPath:indexPath];
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    return viewController.fetchedResultsController.fetchedObjects.count;
}


@end
