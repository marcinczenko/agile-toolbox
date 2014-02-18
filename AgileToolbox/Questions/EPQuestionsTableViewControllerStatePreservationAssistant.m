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

@property (nonatomic,strong) NSURL* idOfTheFirstVisibleRow;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistant

+ (NSString*)persistentStoreFileName
{
    return @"PreservationAssistant.data";
}

+ (NSString*)kBounds
{
    return @"Bounds";
}

+ (NSString*)kScrollDelta
{
    return @"ScrollData";
}

+ (instancetype)restoreFromPersistentStorage
{
    id obj = [EPPersistentStoreHelper unarchiveObjectFromFile:[self persistentStoreFileName]];
    
    if (!obj) {
        obj = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] init];
    }
    return obj;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        _idOfTheFirstVisibleRow = [[NSURL alloc] initWithCoder:aDecoder];
        _snapshotView = [[UIImageView alloc] initWithCoder:aDecoder];
        _bounds = [aDecoder decodeCGRectForKey:[self.class kBounds]];
        _scrollDelta = [aDecoder decodeFloatForKey:[self.class kScrollDelta]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.idOfTheFirstVisibleRow encodeWithCoder:aCoder];
    [self.snapshotView encodeWithCoder:aCoder];
    [aCoder encodeCGRect:self.bounds forKey:[self.class kBounds]];
    [aCoder encodeFloat:self.scrollDelta forKey:[self.class kScrollDelta]];
}

- (void)recordCurrentStateForViewController:(EPQuestionsTableViewController*)viewController
{
    [self createSnapshotViewForViewController:viewController];
    [self storeQuestionIdOfFirstVisibleQuestionForViewController:viewController];
}

- (void)storeToPersistentStorage
{
    [EPPersistentStoreHelper archiveObject:self toFile:[self.class persistentStoreFileName]];
}

- (void)invalidatePersistentStorage
{
    [EPPersistentStoreHelper deleteFile:[self.class persistentStoreFileName]];
}

- (void)createSnapshotViewForViewController:(EPQuestionsTableViewController*)viewController
{
    self.snapshotView = [viewController.tableViewExpert createSnapshotView];
}

- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController
{
    if (viewController.hasQuestionsInPersistentStorage) {
        
        self.idOfTheFirstVisibleRow = [self getArchiveableRepresentationOfIdForIndexPath:[self getIndexPathOfFirstVisibleCellInViewController:viewController]
                                                                        inViewController:viewController];
    }
}

- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController
{
    if (self.idOfTheFirstVisibleRow) {
        NSIndexPath* indexPath = [self indexPathForQuestionURI:self.idOfTheFirstVisibleRow inViewController:viewController];
        if (indexPath) {
            [viewController.tableView scrollToRowAtIndexPath:indexPath
                                            atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        self.idOfTheFirstVisibleRow = nil;
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
    NSIndexPath* indexPath ;
    
    if (-64>viewController.tableView.bounds.origin.y) {
        self.scrollDelta = 0.0;
        indexPath = [viewController.tableView indexPathForRowAtPoint:CGPointMake(0, 1)];
    } else {
        UINavigationBar *navbar = viewController.navigationController.navigationBar;
        CGRect localFrame = [viewController.tableView convertRect:navbar.bounds fromView:navbar];
        CGPoint point = CGPointMake(0, localFrame.origin.y + localFrame.size.height + 1);
        
        indexPath = [viewController.tableView indexPathForRowAtPoint:point];
        
        CGRect rect = [viewController.tableView rectForRowAtIndexPath:indexPath];
        
        CGFloat firstVisibleRowDistanceFromBoundsOrigin = rect.origin.y - viewController.tableView.bounds.origin.y;
        
        CGFloat navBarAndStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + localFrame.size.height;
        
        self.scrollDelta = navBarAndStatusBarHeight - firstVisibleRowDistanceFromBoundsOrigin;
    }
    
    return indexPath;    
}

- (NSURL*)getArchiveableRepresentationOfIdForIndexPath:(NSIndexPath*)indexPath inViewController:(EPQuestionsTableViewController*)viewController
{
    Question* question = [viewController.fetchedResultsController objectAtIndexPath:indexPath];
    return [question.objectID URIRepresentation];
}

- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectID* firstVisibleQuestion = [appDelegate.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    
    __block NSIndexPath* indexPath = nil;
    [viewController.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Question* question, NSUInteger idx, BOOL *stop) {
        if ([firstVisibleQuestion isEqual:question.objectID]) {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    return indexPath;
}

@end
