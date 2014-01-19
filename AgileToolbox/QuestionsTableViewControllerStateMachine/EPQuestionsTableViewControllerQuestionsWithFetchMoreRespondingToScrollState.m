//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "Question.h"
#import "EPQuestionsDataSourceProtocol.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState

- (void)fetchNextSetOfQuestions
{
    Question *question = (Question*)self.viewController.fetchedResultsController.fetchedObjects.lastObject;
    [self.viewController.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewExpert scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView]) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsLoadingState class]];
        [self fetchNextSetOfQuestions];
        [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

@end
