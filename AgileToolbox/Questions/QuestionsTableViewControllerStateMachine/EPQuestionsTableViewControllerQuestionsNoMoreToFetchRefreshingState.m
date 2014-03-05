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

@property (nonatomic,readonly) BOOL isReturningFromQuestionDetailsView;

@property (nonatomic,assign) BOOL hadBeginUpdates;
@property (nonatomic,assign) CGFloat footerHeight;

@end

@implementation EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState

#ifndef KEEP_VISIBLE_TIMEOUT
#define KEEP_VISIBLE_TIMEOUT 2.0
#endif

- (BOOL)isReturningFromQuestionDetailsView
{
    return (nil != self.viewController.refreshControl);
}

- (void)viewWillAppear
{
    if (self.isReturningFromQuestionDetailsView) {
        // when refresh control was visible before leaving the view
        // it may happen that content is slightly misaligned
        // when refresh opration finished in question detail view
        // in background
        if (!self.viewController.refreshControl.isRefreshing) {
            self.tableViewExpert.tableView.contentOffset = CGPointMake(0, 0);
        }
    } else {
        [super viewWillAppear];
    }
}

- (void)viewWillDisappear
{
    if (self.connectionFailurePending) {
        [self handleEvent];
        self.connectionFailurePending = NO;
    }
    
    [super viewWillDisappear];
}

- (void)adjustContentOffsetWhenPositionAtFirstRowAndRefreshingToRevealRefreshControl
{
    if (self.viewController.tableView.bounds.origin.y == -[self.viewController heightOfNavigationBarAndStatusBar] && self.viewController.questionsRefreshControl.isRefreshing) {
        self.viewController.tableView.contentOffset = self.viewController.statePreservationAssistant.bounds.origin;
    }
}

- (void) viewDidAppear
{
    if (!self.viewController.refreshControl) {
        [self.viewController.questionsRefreshControl beginRefreshingWithBeforeBlock:^{
            self.tableViewExpert.tableView.userInteractionEnabled = NO;
            
            [self.viewController.statePreservationAssistant.snapshot displayInView:self.viewController.navigationController.view
                                                                           withTag:1945
                                                            originComputationBlock:^CGPoint{
                return CGPointMake(0, [self.viewController heightOfNavigationBarAndStatusBar]);
            }];
            
        } afterBlock:^{
            
            [super viewDidAppear];
            
            [self adjustContentOffsetWhenPositionAtFirstRowAndRefreshingToRevealRefreshControl];
            
            [self.viewController.statePreservationAssistant.snapshot removeViewWithTag:1945 fromSuperview:self.viewController.navigationController.view];
            
            self.tableViewExpert.tableView.userInteractionEnabled = YES;
        }];
    }
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
    self.contentOffset = self.tableViewExpert.tableView.contentOffset;
    if (-64.0 <= self.contentOffset.y && !self.tableViewExpert.totalContentHeightSmallerThanScreenSizeRefreshAware) {
        self.hadBeginUpdates = NO;
    } else {
        self.footerHeight = self.tableViewExpert.tableView.tableFooterView.frame.size.height;
        [self.tableViewExpert.tableView beginUpdates];
        self.hadBeginUpdates = YES;
    }
    [self.tableViewExpert removeTableFooter];
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
            self.footerHeight -= 105.0;
            if (self.hadBeginUpdates) {
                [self.tableViewExpert.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
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
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.hadBeginUpdates) {
        self.tableViewExpert.tableView.backgroundColor = [UIColor whiteColor];
        if (0<self.footerHeight) {
            [self.tableViewExpert addTableFooterWithHeight:self.footerHeight];
        }
        [self.viewController.questionsRefreshControl endRefreshing];
        [self.tableViewExpert.tableView endUpdates];
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.3 animations:^{
                self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
            }];
        });
        
    } else {
        [self.viewController.questionsRefreshControl endRefreshing];
        [self.tableViewExpert.tableView reloadData];
        self.tableViewExpert.tableView.contentOffset = self.contentOffset ;
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
        [self.viewController.statePreservationAssistant.snapshot clear];
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
    if (self.connectionFailurePending) {
        // It may have happened that on waiting for connection failure completion event
        // we left the screen which means viewWillDisappear happened where we
        // reset all failure indicators and move to appropriate state.
        // In such a case, we should execte the methods below.
        // See also viewWillDisappear.
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
    self.connectionFailurePending = YES;
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
