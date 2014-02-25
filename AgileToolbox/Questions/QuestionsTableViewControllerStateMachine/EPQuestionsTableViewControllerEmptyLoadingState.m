//
//  EPQuestionsTableViewControllerEmptyLoadingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerEmptyConnectionFailureState.h"
#import "EPQuestionsDataSourceProtocol.h"

@implementation EPQuestionsTableViewControllerEmptyLoadingState

- (void)viewWillDisappear
{
    [self.viewController disconnectFromFetchedResultsController];
    
    [super viewWillDisappear];
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    [self.viewController disconnectFromFetchedResultsController];
    
    [super didEnterBackgroundNotification:notification];
}

- (void)dismissHelpOverlay:(id)sender
{
    UIView* helpOverlayView = [self.viewController.navigationController.view viewWithTag:1402241710];
    
    [UIView animateWithDuration:0.5 animations:^{
        helpOverlayView.alpha = 0;
    } completion:^(BOOL finished) {
        [helpOverlayView removeFromSuperview];
    }];
}

- (void)addButtonToView:(UIView*)view withBorderColor:(UIColor*)borderColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(dismissHelpOverlay:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Got it!" forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.borderColor = [borderColor CGColor];
    button.layer.borderWidth = 1.0;
    button.tintColor = [UIColor whiteColor];
    button.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    
    button.frame = CGRectMake(view.bounds.size.width-100-15, view.bounds.size.height-44-15, 100, 44);
    [view addSubview:button];
}

- (void)showHelpOverlay
{
    UIView* helpOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewController.navigationController.view.bounds.size.width, self.viewController.navigationController.view.bounds.size.height)];
    
    UIImage* helpOverlayImage = [UIImage imageNamed:@"QuestionsHelpOverlay"];
    
    UIImageView* helpOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewController.navigationController.view.bounds.size.width, self.viewController.navigationController.view.bounds.size.height)];
    
    helpOverlayImageView.image = helpOverlayImage;
    
    [helpOverlayView addSubview:helpOverlayImageView];
    
    [self addButtonToView:helpOverlayView withBorderColor:[UIColor whiteColor]];
    
    helpOverlayView.alpha = 0.0;
    helpOverlayView.tag = 1402241710;
    
    [self.viewController.navigationController.view addSubview:helpOverlayView];
    
    [UIView animateWithDuration:2.0 animations:^{
        helpOverlayView.alpha = 1.0;
    }];
}

- (void)controllerDidChangeContent
{
    self.viewController.tableView.estimatedRowHeight = 105.0;
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
#ifndef NO_QUESTIONS_HELPER_OVERLAY
        [self showHelpOverlay];
#endif
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
        [self.tableViewExpert deleteFetchMoreCell];
#ifndef NO_QUESTIONS_HELPER_OVERLAY
        [self showHelpOverlay];
#endif
    }
    [self.tableViewExpert.tableView endUpdates];
    [self.viewController.questionsRefreshControl enable];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [EPQuestionsTableViewExpert fetchMoreRowHeight];
}


- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [EPFetchMoreTableViewCell cellDequeuedFromTableView:self.tableViewExpert.tableView
                                                                                     forIndexPath:indexPath
                                                                                          loading:YES];
    
    [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    
    return fetchMoreCell;
}

- (void)fetchReturnedNoData
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)fetchReturnedNoDataInBackground
{
    NSLog(@"fetchReturnedNoDataInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)dataChangedInBackground
{
    [self.viewController.questionsRefreshControl enable];
    self.viewController.tableView.estimatedRowHeight = 105.0;
    NSLog(@"dataChangedInBackground");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert removeTableFooter];
    
    if (self.viewController.questionsDataSource.hasMoreQuestionsToFetch) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
    } else {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]] ;
    }
}

- (void)connectionFailure
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableViewExpert.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)connectionFailureInBackground
{
    NSLog(@"connectionFailureInBackground");
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyConnectionFailureState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return 0;
    } else {
        return 1 ;
    }
}

- (NSInteger)numberOfSections
{
    return 2;
}


@end
