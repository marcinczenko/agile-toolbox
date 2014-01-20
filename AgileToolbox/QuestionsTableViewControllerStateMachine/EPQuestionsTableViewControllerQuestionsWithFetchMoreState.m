//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        if (indexPath.row == [self.tableViewExpert.tableView numberOfRowsInSection:0]-1) {
            [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState class]];
        }
        
        return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                     forIndexPath:indexPath
                                                      andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        return [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                      forIndexPath:indexPath
                                                           loading:NO];
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.viewController.fetchedResultsController.fetchedObjects.count;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}


@end
