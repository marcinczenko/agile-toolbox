//
//  EPQuestionsTableViewControllerStatePreservationAssistant.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 27/01/14.
//
//

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"
#import "EPQuestionsTableViewController.h"
#import "EPPersistentStoreHelper.h"
#import "EPAppDelegate.h"
#import "Question.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistant ()

@property (nonatomic,assign) BOOL viewNeedsRefreshing;
@property (nonatomic,strong) NSURL* idOfTheFirstVisibleRow;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistant

+ (NSString*)persistentStoreFileName
{
    return @"PreservationAssistant.xml";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        _idOfTheFirstVisibleRow = [[NSURL alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.idOfTheFirstVisibleRow encodeWithCoder:aCoder];
}

- (BOOL)viewIsVisibleForViewController:(EPQuestionsTableViewController*)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

- (void)viewController:(EPQuestionsTableViewController*)viewController didEnterBackgroundNotification:(NSNotification*)notification
{
    if ([viewController.stateMachine inQuestionsLoadingState]) {
        viewController.fetchedResultsController.delegate = nil;
        self.viewNeedsRefreshing = YES;
    }
    [self storeToPersistentStorageForViewController:viewController];
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

- (NSIndexPath*)getIndexPathOfFirstVisibleCellInViewController:(EPQuestionsTableViewController*)viewController
{
    UINavigationBar *navbar = viewController.navigationController.navigationBar;
    CGRect localFrame = [viewController.tableView convertRect:navbar.bounds fromView:navbar];
    CGPoint point = CGPointMake(0, localFrame.origin.y + localFrame.size.height + 1);
    
    return [self adjustIndexPath:[viewController.tableView indexPathForRowAtPoint:point]
                                                       forTableView:viewController.tableView
                                                 withRespectToFrame:localFrame];
}

- (NSURL*)getArchiveableRepresentationOfIdForIndexPath:(NSIndexPath*)indexPath inViewController:(EPQuestionsTableViewController*)viewController
{
    Question* question = [viewController.fetchedResultsController objectAtIndexPath:indexPath];
    return [question.objectID URIRepresentation];
}

- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController
{
    if (0<viewController.fetchedResultsController.fetchedObjects.count) {
        
        self.idOfTheFirstVisibleRow = [self getArchiveableRepresentationOfIdForIndexPath:[self getIndexPathOfFirstVisibleCellInViewController:viewController]
                                                                        inViewController:viewController];
    }
}

- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController
{
    __block NSIndexPath* indexPath = nil;
    [viewController.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Question* question, NSUInteger idx, BOOL *stop) {
        EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectID* firstVisibleQuestion = [appDelegate.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        if ([firstVisibleQuestion isEqual:question.objectID]) {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    return indexPath;
}

- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController
{
    if (self.idOfTheFirstVisibleRow) {
        [viewController.tableView reloadData];
        NSIndexPath* indexPath = [self indexPathForQuestionURI:self.idOfTheFirstVisibleRow inViewController:viewController];
        if (indexPath) {
            [viewController.tableView scrollToRowAtIndexPath:indexPath
                                            atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        self.idOfTheFirstVisibleRow = nil;
    }
}

- (void)storeToPersistentStorageForViewController:(EPQuestionsTableViewController*)viewController
{
    [self storeQuestionIdOfFirstVisibleQuestionForViewController:viewController];
    if (self.idOfTheFirstVisibleRow) {
        [EPPersistentStoreHelper archiveObject:self toFile:[self.class persistentStoreFileName]];
    }
}

+ (instancetype)restoreFromPersistentStorage
{
    id obj = [EPPersistentStoreHelper unarchiveObjectFromFile:[self persistentStoreFileName]];
    
    if (!obj) {
        obj = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] init];
    }
    return obj;
}

@end
