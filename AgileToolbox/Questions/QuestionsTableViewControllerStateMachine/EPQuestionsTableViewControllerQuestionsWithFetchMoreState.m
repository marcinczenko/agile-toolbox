//
//  EPQuestionsTableViewControllerQuestionsWithFetchMoreState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingRefreshingState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsWithFetchMoreState

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.viewController.questionsRefreshControl enable];
}

- (void)viewWillAppear
{
    [self.viewController.questionsRefreshControl enable];
    [super viewWillAppear];
}

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
                                                           loading:NO];
    }
}

- (void)refresh:(UIRefreshControl*)refreshControl
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreRefreshingState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.viewController.questionsRefreshControl.title = EPQuestionsRefreshControlTextRefreshing;
    
    [self.viewController.questionsDataSource fetchNewAndUpdatedGivenMostRecentQuestionId:self.viewController.mostRecentQuestionId
                                                                     andOldestQuestionId:self.viewController.oldestQuestionId];
    
}

- (void)fetchNextSetOfQuestions
{
    Question *question = (Question*)self.viewController.fetchedResultsController.fetchedObjects.lastObject;
    [self.viewController.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewExpert scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView]) {
        self.viewController.isScrolling = NO;
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsLoadingRefreshingState class]];
        [self fetchNextSetOfQuestions];
        [self.tableViewExpert.fetchMoreCell setLoadingStatus:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [self.viewController.questionsRefreshControl beginRefreshing];
        
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.viewController.numberOfQuestionsInPersistentStorage;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}


@end
