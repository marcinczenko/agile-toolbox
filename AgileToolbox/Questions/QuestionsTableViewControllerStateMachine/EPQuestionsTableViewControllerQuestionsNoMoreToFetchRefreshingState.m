//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState ()

@property (nonatomic,assign) CGPoint contentOffset;


@end

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState

#ifndef KEEP_VISIBLE_TIMEOUT
#define KEEP_VISIBLE_TIMEOUT 2.0
#endif

- (void)viewWillAppear
{
    if (!self.viewController.refreshControl) {
        [super viewWillAppear];
    }
}

- (void)viewWillDisappear
{
    if (self.connectionFailureFlag) {
        [self handleEvent];
        self.connectionFailureFlag = NO;
    }
    
    [super viewWillDisappear];
}

- (void) viewDidAppear
{
    if (!self.viewController.refreshControl) {
        [self.viewController.questionsRefreshControl beginRefreshingWithBeforeBlock:^{
            self.tableViewExpert.tableView.userInteractionEnabled = NO;
            
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            frame.origin = CGPointMake(0, 64.0);
            
            UIImageView* snapshotCopy = [[UIImageView alloc] initWithImage:self.viewController.statePreservationAssistant.snapshotView.image];
            
            snapshotCopy.frame = frame;
            snapshotCopy.tag = 1945;
            
            [self.viewController.navigationController.view addSubview:snapshotCopy];
            
            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
            
        } afterBlock:^{
            
            [super viewDidAppear];
            
            if (self.viewController.tableView.bounds.origin.y == -64.0 && self.viewController.questionsRefreshControl.isRefreshing) {
//                CGRect r = self.viewController.tableView.bounds;
//                r.origin.y -= self.viewController.refreshControl.frame.size.height;
                self.viewController.tableView.contentOffset = self.viewController.statePreservationAssistant.bounds.origin;
            }
            
            UIView* view = [self.viewController.navigationController.view viewWithTag:1945];
            
            view.hidden = YES;
            [view removeFromSuperview];
            self.tableViewExpert.tableView.userInteractionEnabled = YES;
        }];
    }
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

- (NSInteger)numberOfSections
{
    return 1;
}

- (void)handleEvent
{
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.viewController.questionsRefreshControl endRefreshing];
}

- (void)controllerWillChangeContent
{
    [self.tableViewExpert removeTableFooter];
    self.contentOffset = self.tableViewExpert.tableView.contentOffset;
}

- (void)controllerDidChangeQuestion:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    EPQuestionTableViewCell* updatedCell;
    CGPoint contentOffset;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            contentOffset = self.contentOffset;
            contentOffset.y += 105.0;
            self.contentOffset = contentOffset;
            break;
        case NSFetchedResultsChangeUpdate:
            updatedCell = (EPQuestionTableViewCell*)[self.tableViewExpert.tableView cellForRowAtIndexPath:indexPath];
            [updatedCell formatCellForQuestion:question];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent
{
    [self handleEvent];
    [self.tableViewExpert.tableView reloadData];
    self.tableViewExpert.tableView.contentOffset = self.contentOffset;
    
    if (self.tableViewExpert.totalContentHeightSmallerThanScreenSize) {
        [self.tableViewExpert addTableFooterInOrderToHideEmptyCells];
    }
}

- (void)dataChangedInBackground
{
    [self handleEvent];
    [self checkAndCancelRestoringScrollPosition];
}

- (void)fetchReturnedNoData
{
    [self handleEvent];
}

- (void)checkAndCancelRestoringScrollPosition
{
    if (-64.0>=self.viewController.statePreservationAssistant.bounds.origin.y) {
        // cancel restoring scrol position
        self.viewController.statePreservationAssistant.snapshotView = nil;
        [self.viewController.statePreservationAssistant invalidatePersistentStorage];
    }
}

- (void)fetchReturnedNoDataInBackground
{
    NSLog(@"fetchReturnedNoDataInBackground");
    [self handleEvent];
    [self checkAndCancelRestoringScrollPosition];
}

- (void)keepVisibleFor:(double)seconds completionBlock:(void (^)())block
{
    double delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void)handleConnectionFailureUsingNativeRefreshControlCompletionHandler
{
    if (self.connectionFailureFlag) {
        [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
        
        [self.viewController.questionsRefreshControl endRefreshing];
    }    
}

- (void)handleConnectionFailureUsingNativeRefreshControl
{
    self.viewController.questionsRefreshControl.title = EPFetchMoreTableViewCellTextConnectionFailure;
    
    [self keepVisibleFor:KEEP_VISIBLE_TIMEOUT completionBlock:^{
        [self handleConnectionFailureUsingNativeRefreshControlCompletionHandler];
    }];
}

- (void)connectionFailure
{
    self.connectionFailureFlag = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self handleConnectionFailureUsingNativeRefreshControl];
}

- (void)connectionFailureInBackground
{
    NSLog(@"connectionFailureInBackground");
    [self handleEvent];
    [self checkAndCancelRestoringScrollPosition];
}



@end
