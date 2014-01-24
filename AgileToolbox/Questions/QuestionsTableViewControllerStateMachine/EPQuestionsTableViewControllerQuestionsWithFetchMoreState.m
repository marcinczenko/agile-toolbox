//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
//#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreState


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                     forIndexPath:indexPath
                                                      andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        return [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                      forIndexPath:indexPath
                                                           loading:NO];
    }
}

- (void)fetchNextSetOfQuestions
{
    Question *question = (Question*)self.viewController.fetchedResultsController.fetchedObjects.lastObject;
    [self.viewController.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsLoadingState class]];
    [self fetchNextSetOfQuestions];
    [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
