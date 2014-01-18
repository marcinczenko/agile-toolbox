//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "Question.h"
#import "EPQuestionsDataSourceProtocol.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState

+ (id)instance
{
    static EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerQuestionsWithFetchMoreLastRowVisibleState alloc] init];
    }
    return instance;
}

- (void)fetchNextSetOfQuestions:(EPQuestionsTableViewController*)viewController
{
    Question *question = (Question*)viewController.fetchedResultsController.fetchedObjects.lastObject;
    [viewController.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (void)activateFetchIndicatorsFor:(EPQuestionsTableViewController*)viewController
{
    EPFetchMoreTableViewCell* fetchMoreCell = (EPFetchMoreTableViewCell*)[viewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    fetchMoreCell.label.hidden = YES;
    [fetchMoreCell.activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)viewController:(EPQuestionsTableViewController*)viewController scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView]) {
        viewController.state = [EPQuestionsTableViewControllerQuestionsLoadingState instance];
        [self fetchNextSetOfQuestions:viewController];
        [self activateFetchIndicatorsFor:viewController];
    }
}

@end
