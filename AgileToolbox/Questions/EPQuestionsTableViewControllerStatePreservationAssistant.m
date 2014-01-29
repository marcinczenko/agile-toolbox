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
#import "Question.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistant ()

@property (nonatomic,strong) NSNotificationCenter* notificationCenter;
@property (nonatomic,copy) NotificationHandlerBlockType willEnterForegroundNotificationBlock;
@property (nonatomic,copy) NotificationHandlerBlockType didBecomeActiveNotificationBlock;

@property (nonatomic,assign) BOOL viewNeedsRefreshing;
@property (nonatomic,strong) NSNumber* idOfTheFirstVisibleRow;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistant

+ (NSString*)persistentStoreFileName
{
    return @"PreservationAssistant.xml";
}

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

- (NSNumber*)getIdCorrespondingToIndexPath:(NSIndexPath*)indexPath inViewController:(EPQuestionsTableViewController*)viewController
{
    Question* question = [viewController.fetchedResultsController objectAtIndexPath:indexPath];
    return question.question_id;
}

- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController
{
    if (0<viewController.fetchedResultsController.fetchedObjects.count) {
        
        self.idOfTheFirstVisibleRow = [self getIdCorrespondingToIndexPath:[self getIndexPathOfFirstVisibleCellInViewController:viewController]
                                                         inViewController:viewController];
    }
}

- (NSIndexPath*)indexPathForQuestionId:(NSNumber*)id inViewController:(EPQuestionsTableViewController*)viewController
{
    __block NSIndexPath* indexPath = nil;
    [viewController.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Question* question, NSUInteger idx, BOOL *stop) {
        if (self.idOfTheFirstVisibleRow == question.question_id) {
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
        NSIndexPath* indexPath = [self indexPathForQuestionId:self.idOfTheFirstVisibleRow inViewController:viewController];
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
        [EPPersistentStoreHelper storeDictionary:@{@"FirstVisibleQuestionId":self.idOfTheFirstVisibleRow}
                                          toFile:[self.class persistentStoreFileName]];
    }
}

- (void)restoreFromPersistentStorage
{
    NSDictionary* dataDictionary = [EPPersistentStoreHelper readDictionaryFromFile:[self.class persistentStoreFileName]];
    
    if (dataDictionary) {
        if (dataDictionary[@"FirstVisibleQuestionId"]) {
            self.idOfTheFirstVisibleRow = dataDictionary[@"FirstVisibleQuestionId"];
        }
    }
}

@end
