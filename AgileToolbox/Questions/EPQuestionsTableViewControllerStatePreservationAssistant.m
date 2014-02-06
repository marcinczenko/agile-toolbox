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

+ (NSString*)contentOffsetKey
{
    return @"ContentOffset";
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
        _contentOffset = [aDecoder decodeCGPointForKey:[self.class contentOffsetKey]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.idOfTheFirstVisibleRow encodeWithCoder:aCoder];
    [self.snapshotView encodeWithCoder:aCoder];
    [aCoder encodeCGPoint:self.contentOffset forKey:[self.class contentOffsetKey]];
}

- (void)recordCurrentStateForViewController:(EPQuestionsTableViewController*)viewController
{
    [self createSnapshotViewForViewController:viewController];
    [self storeQuestionIdOfFirstVisibleQuestionForViewController:viewController];
    [self storeContentOffsetForViewController:viewController];
}

- (void)storeToPersistentStorage
{
    [EPPersistentStoreHelper archiveObject:self toFile:[self.class persistentStoreFileName]];
}

- (void)createSnapshotViewForViewController:(EPQuestionsTableViewController*)viewController
{
    self.snapshotView = [viewController.tableViewExpert createSnapshotView];
}

- (void)storeContentOffsetForViewController:(EPQuestionsTableViewController*)viewController
{
    self.contentOffset = viewController.tableViewExpert.tableView.contentOffset;
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
        [viewController.tableView reloadData];
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

@end
