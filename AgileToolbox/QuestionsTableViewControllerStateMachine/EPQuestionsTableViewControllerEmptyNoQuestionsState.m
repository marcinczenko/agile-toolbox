//
//  EPQuestionsTableViewControllerEmptyNoQuestionsState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"

@implementation EPQuestionsTableViewControllerEmptyNoQuestionsState

+ (id)instance
{
    static EPQuestionsTableViewControllerEmptyNoQuestionsState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerEmptyNoQuestionsState alloc] init];
    }
    return instance;
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [viewController.tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                                                              forIndexPath:indexPath];
    
    fetchMoreCell.label.text = @"No questions on the server";
    
    [self addTableFooterViewInOrderToHideEmptyCellsIn:viewController];
    
    return fetchMoreCell;
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
