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

//@property (nonatomic,assign) BOOL renderRefreshLoading;
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
    self.viewController.statePreservationAssistant.bounds = self.tableViewExpert.tableView.bounds;
    
    [super viewWillDisappear];
}

//- (void) viewDidAppear
//{
//    if (!self.viewController.refreshControl) {
//        [self.viewController.questionsRefreshControl beginRefreshingWithBeforeBlock:^{
//            self.tableViewExpert.tableView.userInteractionEnabled = NO;
//            
//            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
//            frame.origin = CGPointMake(0, 64.0);
//            
//            UIImageView* snapshotCopy = [[UIImageView alloc] initWithImage:self.viewController.statePreservationAssistant.snapshotView.image];
//            
//            snapshotCopy.frame = frame;
//            snapshotCopy.tag = 1945;
//            
//            [self.viewController.navigationController.view addSubview:snapshotCopy];
//            
//            NSLog(@"CCcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
//            NSLog(@"CCcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
//            
//            //                    if (self.viewController.tableView.contentOffset.y == -64) {
//            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
//            //                    }
//            
//            NSLog(@"DDcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
//            NSLog(@"DDcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
//        } afterBlock:^{
//            NSLog(@"EEcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
//            NSLog(@"EEcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
//            
//            NSLog(@"INITIAL_BOUNDS:%@",NSStringFromCGRect(self.viewController.statePreservationAssistant.bounds));
//            
//            [super viewDidAppear];
//            
//            if (self.viewController.tableView.bounds.origin.y == -64.0 && self.viewController.autoInitRefreshControl.isRefreshing) {
//                CGRect r = self.viewController.tableView.bounds;
//                r.origin.y -= self.viewController.refreshControl.frame.size.height;
//                //                            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
//                self.viewController.tableView.contentOffset = self.viewController.statePreservationAssistant.bounds.origin;
//            }
//            
//            UIView* view = [self.viewController.navigationController.view viewWithTag:1945];
//            
//            view.hidden = YES;
//            [view removeFromSuperview];
//            self.tableViewExpert.tableView.userInteractionEnabled = YES;
//        }];
//    }
//}


- (void) viewDidAppear
{
    NSLog(@"AAcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
    NSLog(@"AAcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
    
    if (!self.viewController.refreshControl) {
        
        UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
        //        UIRefreshControl* refreshControl = self.viewController.questionsRefreshControl;
        
        UIFont* headerFont = [UIFont fontWithName:@"Helvetica-Light" size:10];
        
        NSAttributedString* attributedTitle =  [[NSAttributedString alloc] initWithString:@"Refreshing...!"
                                                                               attributes: @{ NSFontAttributeName: headerFont,
                                                                                              NSForegroundColorAttributeName: [UIColor blackColor]}];
        
        refreshControl.attributedTitle = attributedTitle;
        
        
        [refreshControl addTarget:self.viewController
                           action:@selector(refresh:)
                 forControlEvents:UIControlEventValueChanged];
        
        
        self.viewController.refreshControl = refreshControl;
        
        NSLog(@"BBcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        NSLog(@"BBcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
        
        self.tableViewExpert.tableView.userInteractionEnabled = NO;
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [self.viewController.refreshControl beginRefreshing];
        
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [self.viewController.refreshControl endRefreshing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            frame.origin = CGPointMake(0, 64.0);
            
            UIImageView* snapshotCopy = [[UIImageView alloc] initWithImage:self.viewController.statePreservationAssistant.snapshotView.image];
            
            snapshotCopy.frame = frame;
            snapshotCopy.tag = 1945;
            
            [self.viewController.navigationController.view addSubview:snapshotCopy];
            
            NSLog(@"CCcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
            NSLog(@"CCcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
            
            //                    if (self.viewController.tableView.contentOffset.y == -64) {
            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
            //                    }
            
            NSLog(@"DDcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
            NSLog(@"DDcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
            
            [self.viewController.refreshControl beginRefreshing];
            
            //                    double delayInSeconds = 5.0;
            //                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            //                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //                        NSLog(@"EEcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
            //                        NSLog(@"EEcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
            //
            //                        NSLog(@"INITIAL_BOUNDS:%@",NSStringFromCGRect(self.viewController.statePreservationAssistant.bounds));
            //
            //                        [super viewDidAppear];
            //
            //                        if (self.viewController.tableView.bounds.origin.y == -64.0 && self.viewController.refreshControl.isRefreshing) {
            //                            CGRect r = self.viewController.tableView.bounds;
            //                            r.origin.y -= self.viewController.refreshControl.frame.size.height;
            //                            //                            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
            //                            self.viewController.tableView.contentOffset = self.viewController.statePreservationAssistant.bounds.origin;
            //                        }
            //
            //                        UIView* view = [self.viewController.navigationController.view viewWithTag:1945];
            //
            //                        view.hidden = YES;
            //                        [view removeFromSuperview];
            //                    });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"EEcontentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
                NSLog(@"EEcontentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
                
                NSLog(@"INITIAL_BOUNDS:%@",NSStringFromCGRect(self.viewController.statePreservationAssistant.bounds));
                
                [super viewDidAppear];
                
                if (self.viewController.tableView.bounds.origin.y == -64.0 && self.viewController.autoInitRefreshControl.isRefreshing) {
                    CGRect r = self.viewController.tableView.bounds;
                    r.origin.y -= self.viewController.refreshControl.frame.size.height;
                    //                            self.viewController.tableView.contentOffset = CGPointMake(0, -64-self.viewController.refreshControl.frame.size.height);
                    self.viewController.tableView.contentOffset = self.viewController.statePreservationAssistant.bounds.origin;
                }
                
                UIView* view = [self.viewController.navigationController.view viewWithTag:1945];
                
                view.hidden = YES;
                [view removeFromSuperview];
                self.tableViewExpert.tableView.userInteractionEnabled = YES;
                
            });
        });
        //            });
        
        //        });
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
    [self.viewController endRefreshing];
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
    }
}

- (void)fetchReturnedNoDataInBackground
{
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
    [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
    
    [self.viewController endRefreshing];
}

- (void)handleConnectionFailureUsingNativeRefreshControl
{
    [self.viewController setRefreshControlText:EPFetchMoreTableViewCellTextConnectionFailure];
    
    [self keepVisibleFor:KEEP_VISIBLE_TIMEOUT completionBlock:^{
        [self handleConnectionFailureUsingNativeRefreshControlCompletionHandler];
    }];
}

- (void)connectionFailure
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self handleConnectionFailureUsingNativeRefreshControl];
}

- (void)connectionFailureInBackground
{
    [self handleEvent];
}



@end
