//
//  EPQuestionsTableViewControllerStatePreservationAssistant.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 27/01/14.
//
//

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"
#import "EPQuestionsTableViewController.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistant ()

@property (nonatomic,strong) NSNotificationCenter* notificationCenter;
@property (nonatomic,copy) NotificationHandlerBlockType willEnterForegroundNotificationBlock;
@property (nonatomic,copy) NotificationHandlerBlockType didBecomeActiveNotificationBlock;

@property (nonatomic,assign) BOOL viewNeedsRefreshing;
@property (nonatomic,strong) NSIndexPath* indexPathOfFirstVisibleRow;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistant

- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (BOOL)viewIsVisibleForViewController:(EPQuestionsTableViewController*)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

- (void)viewController:(EPQuestionsTableViewController*)viewController didEnterBackgroundNotification:(NSNotification*)notification
{
    if ([viewController.stateMachine isLoading]) {
        viewController.fetchedResultsController.delegate = nil;
        self.viewNeedsRefreshing = YES;
    }
}

- (void)viewController:(EPQuestionsTableViewController*)viewController willEnterForegroundNotification:(NSNotification*)notification
{
    if (self.viewNeedsRefreshing) {
        NSLog(@"questionsTableViewController:BLOCK: UIApplicationWillEnterForegroundNotification");
        
        viewController.fetchedResultsController.delegate = viewController;
        NSError *fetchError = nil;
        [viewController.fetchedResultsController performFetch:&fetchError];
    }
}

- (void)viewController:(EPQuestionsTableViewController*)viewController didBecomeActiveNotification:(NSNotification*)notification
{
    if (self.viewNeedsRefreshing) {
        self.viewNeedsRefreshing = NO;
        if ([self viewIsVisibleForViewController:viewController]) {
            NSLog(@"questionsTableViewController:BLOCK: UIApplicationDidBecomeActiveNotification");
            
            [viewController.tableView reloadData];
        }
    }
}

- (NSIndexPath*)adjustIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView withRespectToFrame:(CGRect)frame
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGPoint point = CGPointMake(0, frame.origin.y + frame.size.height + cell.bounds.size.height/2 + 1);
    return [tableView indexPathForRowAtPoint:point];
}

- (void)storeIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController
{
    UINavigationBar *navbar = viewController.navigationController.navigationBar;
    CGRect localFrame = [viewController.tableView convertRect:navbar.bounds fromView:navbar];
    CGPoint point = CGPointMake(0, localFrame.origin.y + localFrame.size.height + 1);
    
    self.indexPathOfFirstVisibleRow = [self adjustIndexPath:[viewController.tableView indexPathForRowAtPoint:point]
                                               forTableView:viewController.tableView
                                         withRespectToFrame:localFrame];
}

- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController
{
    if (self.indexPathOfFirstVisibleRow) {
        NSLog(@"storedIndex:%@",self.indexPathOfFirstVisibleRow);
        [viewController.tableView reloadData];
        [viewController.tableView scrollToRowAtIndexPath:self.indexPathOfFirstVisibleRow
                                        atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.indexPathOfFirstVisibleRow = nil;
    }
}

@end
