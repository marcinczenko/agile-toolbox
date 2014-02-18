//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h"
#import "EPQuestionTableViewCell.h"

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchState

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.viewController setupRefreshControl];
}

- (void)viewWillAppear
{
    [self.viewController setupRefreshControl];
    [super viewWillAppear];
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
        [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    }
    return [EPQuestionTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                 forIndexPath:indexPath
                                                  andQuestion:[self.viewController.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return self.viewController.numberOfQuestionsInPersistentStorage;
}

- (void)refresh:(UIRefreshControl*)refreshControl
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIFont* headerFont = [UIFont fontWithName:@"Helvetica-Light" size:10];
    
    NSAttributedString* attributedTitle =  [[NSAttributedString alloc] initWithString:@"Refreshing...!"
                                                                           attributes: @{ NSFontAttributeName: headerFont,
                                                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    refreshControl.attributedTitle = attributedTitle;
    
    [self.viewController.questionsDataSource fetchNewAndUpdatedGivenMostRecentQuestionId:self.viewController.mostRecentQuestionId
                                                                     andOldestQuestionId:self.viewController.oldestQuestionId];
    
}



@end
