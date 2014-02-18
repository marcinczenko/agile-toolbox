//
//  EPQuestionsTableViewControllerState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsTableViewControllerStateMachine.h"

#import "EPQuestionDetailsTableViewController.h"
#import "EPAddQuestionViewController.h"

#import "EPPersistentStoreHelper.h"

@interface EPQuestionsTableViewControllerState ()

@property (nonatomic,weak) EPQuestionsTableViewControllerStateMachine *stateMachine;

@end

@implementation EPQuestionsTableViewControllerState

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController
             tableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
             andStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    if ((self = [super init])) {
        _viewController = viewController;
        _tableViewExpert = tableViewExpert;
        _stateMachine = stateMachine;
    }
    
    return self;
}

- (id)initWithStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    return [self initWithViewController:nil tableViewExpert:nil andStateMachine:stateMachine];
}

- (void)enterForeground
{
    self.viewController.statePreservationAssistant.viewNeedsRefreshing = NO;
    self.viewController.questionsDataSource.backgroundFetchMode = NO;
    self.viewController.fetchedResultsController.delegate = self.viewController;
    [self refetchFromCoreData];
    [self.tableViewExpert.tableView reloadData];
}

- (void)refetchFromCoreData
{
    NSError *fetchError = nil;
    [self.viewController.fetchedResultsController performFetch:&fetchError];
}

- (void)viewDidLoad
{
    
}

- (UIImage*)drawCircle:(UIColor*) color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(15,15), NO, 0);
    UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,15,15)];
    [color setFill];
    [circle fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)viewWillAppear
{
    if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
        [self enterForeground];
    }
    
//    if (self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration) {
//        return;
//    }
    
//    if (self.viewController) {
//        <#statements#>
//    }
    
    if (self.viewController.statePreservationAssistant.snapshotView) {
        if (0<=self.viewController.statePreservationAssistant.contentOffset.y) {
            self.tableViewExpert.tableView.backgroundColor = [UIColor whiteColor];
        } else {
            self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
        }
        
        NSLog(@"TURBO-BEFORE:%@",NSStringFromCGRect(self.viewController.statePreservationAssistant.snapshotView.frame));
        
        NSLog(@"Size[BEFORE]:%@",NSStringFromCGSize(self.viewController.tableView.contentSize));
        NSLog(@"XXcontentOffset[BEFORE]:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        NSLog(@"XXcontentInset[BEFORE]:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
        NSLog(@"XXbounds-before:%@",NSStringFromCGRect(self.tableViewExpert.tableView.bounds));
        
//        self.viewController.statePreservationAssistant.snapshotView.frame = CGRectMake(0,self.viewController.tableView.bounds.origin.y+64.0, self.viewController.statePreservationAssistant.snapshotView.frame.size.width, self.viewController.statePreservationAssistant.snapshotView.frame.size.height);
        
        NSLog(@"iViewLoaded? %d",self.viewController.isViewLoaded);
        NSLog(@"isViewIsVisible? %d",self.viewController.viewIsVisible);
        // Q: contentSize or better contentInset?
        // A: contentSize is set when bounds are set even though contentInset is still not set
        //    when bounds are non-zero it is save to position the contents
        // Notice: isViewLoaded is set to 1 regardless, so it is useless in this case
        //         view.window is nill in both cases.
        if (0==self.tableViewExpert.tableView.contentSize.height) {
            // view dimensions are not yet calculated - we operate in a simplified frame
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            if (self.viewController.refreshControl.isRefreshing) {
                frame.origin = CGPointMake(0, -self.viewController.refreshControl.frame.size.height);
            } else {
                frame.origin = CGPointMake(0, 0);
            }
            
            self.viewController.statePreservationAssistant.snapshotView.frame = frame;
        } else {
            CGRect frame = self.viewController.statePreservationAssistant.snapshotView.frame;
            if (self.viewController.refreshControl.isRefreshing) {
                frame.origin = CGPointMake(0, self.viewController.tableView.bounds.origin.y+self.viewController.tableView.contentInset.top-self.viewController.refreshControl.frame.size.height);
            } else {
                frame.origin = CGPointMake(0, self.viewController.tableView.bounds.origin.y+self.viewController.tableView.contentInset.top);
            }
            
            self.viewController.statePreservationAssistant.snapshotView.frame = frame;
        }
        
        NSLog(@"TURBO:%@",NSStringFromCGRect(self.viewController.statePreservationAssistant.snapshotView.frame));
        NSLog(@"Size[AFTER]:%@",NSStringFromCGSize(self.viewController.tableView.contentSize));
        NSLog(@"XXcontentOffset[AFTER]:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        NSLog(@"XXcontentInset[AFTER]:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
        NSLog(@"XXbounds-after:%@",NSStringFromCGRect(self.tableViewExpert.tableView.bounds));
        
//        self.viewController.statePreservationAssistant.snapshotView.alpha = 0.7;
        
        [self.tableViewExpert.tableView addSubview:self.viewController.statePreservationAssistant.snapshotView];
    } else {
        NSLog(@"contentOffset[STR]=%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        self.tableViewExpert.tableView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)viewDidAppear
{
    if (!self.tableViewExpert.refreshControl) {
        self.tableViewExpert.tableView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    }

    
    
//    if (self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration) {
//        self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration = NO;
//        self.viewController.statePreservationAssistant.snapshotView = nil;
//        return;
//    }
    
    if (self.viewController.statePreservationAssistant.snapshotView) {
        NSLog(@"EEcontentOffset[BEFORE]:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        NSLog(@"EEcontentInset[BEFORE]:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
        NSLog(@"bounds-before-scroll:%@",NSStringFromCGRect(self.tableViewExpert.tableView.bounds));
        [self.viewController.statePreservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.viewController];
        NSLog(@"EEcontentOffset[AFTER]:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
        NSLog(@"EEcontentInset[AFTER]:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
        NSLog(@"bounds-after-scroll:%@",NSStringFromCGRect(self.tableViewExpert.tableView.bounds));
//        CGFloat currentBoundsOriginY = self.tableViewExpert.tableView.bounds.origin.y;
        
//        CGFloat adjustedDelta = 64.0 - self.viewController.statePreservationAssistant.firstVisibleRowDistanceFromBoundsOrigin;
//        CGRect correctedBounds = self.viewController.tableView.bounds;
//        correctedBounds.origin.y += adjustedDelta;
        
        CGRect correctedBounds = self.viewController.tableView.bounds;
        correctedBounds.origin.y += self.viewController.statePreservationAssistant.scrollDelta;

        
        
        
//        self.tableViewExpert.tableView.bounds = self.viewController.statePreservationAssistant.bounds;
        self.tableViewExpert.tableView.bounds = correctedBounds;
        NSLog(@"bounds-adjusted-scroll:%@",NSStringFromCGRect(self.tableViewExpert.tableView.bounds));
        self.viewController.statePreservationAssistant.snapshotView.hidden = YES;
        [self.viewController.statePreservationAssistant.snapshotView removeFromSuperview];
        self.viewController.statePreservationAssistant.snapshotView = nil;
    }
}

- (void)viewWillDisappear
{
    if (-64.0>self.tableViewExpert.tableView.bounds.origin.y && !self.viewController.refreshControl.isRefreshing) {
        return ;
    }
    
    NSLog(@"contentOffset:%@",NSStringFromCGPoint(self.viewController.tableView.contentOffset));
    NSLog(@"contentInset:%@",NSStringFromUIEdgeInsets(self.viewController.tableView.contentInset));
//    self.viewController.refreshControl = nil;
    
    self.viewController.statePreservationAssistant.bounds = self.viewController.tableView.bounds;
    NSLog(@"viewWillDissapper-bounds:%@",NSStringFromCGRect(self.viewController.tableView.bounds));
    CGRect ceiledBounds = self.viewController.tableView.bounds;
    ceiledBounds.origin.y = ceil(ceiledBounds.origin.y);
    self.viewController.statePreservationAssistant.bounds = ceiledBounds;
    NSLog(@"viewWillDissapper-bounds-adjusted:%@",NSStringFromCGRect(ceiledBounds));
    
    if (self.viewController.hasQuestionsInPersistentStorage) {
        [self.viewController.statePreservationAssistant recordCurrentStateForViewController:self.viewController];
        NSData* imageData = UIImageJPEGRepresentation(self.viewController.statePreservationAssistant.snapshotView.image, 1.0);
        
        NSURL* path = [EPPersistentStoreHelper persistentStateURLForFile:@"image-willDisspaper.jpg"];
        
        [imageData writeToFile:path.path atomically:NO];
    }
}

- (void)willResignActiveNotification:(NSNotification*)notification
{
    if (self.viewController.viewIsVisible && self.viewController.hasQuestionsInPersistentStorage) {
        [self.viewController.statePreservationAssistant recordCurrentStateForViewController:self.viewController];
    }
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    [self.viewController.statePreservationAssistant storeToPersistentStorage];
    [self.viewController.questionsDataSource storeToPersistentStorage];
}

- (void)willEnterForegroundNotification:(NSNotification*)notification
{
    if ([self.viewController viewIsVisible]) {
        if (self.viewController.statePreservationAssistant.viewNeedsRefreshing) {
            NSLog(@"questionsTableViewController:BLOCK: UIApplicationWillEnterForegroundNotification");
            
            [self enterForeground];
            
            [self.tableViewExpert.tableView reloadData];
        }
    }
}

- (void)didBecomeActiveNotification:(NSNotification*)notification
{
    
}

- (void)controllerWillChangeContent
{
    [self.tableViewExpert removeTableFooter];
    [self.tableViewExpert.tableView beginUpdates];
}

- (void)controllerDidChangeQuestion:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    [self.tableViewExpert.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
}


- (void)controllerDidChangeContent
{
    
}

- (void)fetchReturnedNoData
{
    
}

- (void)fetchReturnedNoDataInBackground
{
    
}

- (void)dataChangedInBackground
{
    
}

- (void)connectionFailure
{
    
}

- (void)connectionFailureInBackground
{
    
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [EPQuestionsTableViewExpert questionRowHeight];
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (void)refresh:(UIRefreshControl*)refreshControl
{
    
}

- (Question*) questionObjectForIndexPath:(NSIndexPath*)indexPath
{
    return [self.viewController.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)skipRefreshing
{
    self.viewController.statePreservationAssistant.skipTableViewScrollPositionRestoration = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"AddQuestion"]) {
        
        UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
        
        EPAddQuestionViewController* destinationVC =  (EPAddQuestionViewController*)navigationController.topViewController;
        destinationVC.delegate = self.viewController;
    } else if ([segue.identifier isEqualToString:@"QuestionDetails"]) {
        EPQuestionDetailsTableViewController* questionDetailsViewController = (EPQuestionDetailsTableViewController*)segue.destinationViewController;
        
        questionDetailsViewController.question = [self questionObjectForIndexPath:[self.tableViewExpert.tableView indexPathForSelectedRow]];
        
        [self skipRefreshing];
    }
}

@end
