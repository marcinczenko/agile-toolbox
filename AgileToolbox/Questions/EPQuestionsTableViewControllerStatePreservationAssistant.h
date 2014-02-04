//
//  EPQuestionsTableViewControllerStatePreservationAssistant.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 27/01/14.
//
//

#import <Foundation/Foundation.h>
@class EPQuestionsTableViewController;

@interface EPQuestionsTableViewControllerStatePreservationAssistant : NSObject<NSCoding>

@property (nonatomic,readonly) BOOL viewNeedsRefreshing;
@property (nonatomic,readonly) NSURL* idOfTheFirstVisibleRow;

@property (nonatomic,strong) UIImageView* snapshotView;
@property (nonatomic,assign) CGPoint contentOffset;

+ (instancetype)restoreFromPersistentStorage;

- (void)viewController:(EPQuestionsTableViewController*)viewController willResignActiveNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController didEnterBackgroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController willEnterForegroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController didBecomeActiveNotification:(NSNotification*)notification;
- (void)viewWillAppearForViewController:(EPQuestionsTableViewController*)viewController;
- (void)viewDidAppearForViewController:(EPQuestionsTableViewController*)viewController;
- (void)viewWillDisappearForViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController;
- (void)createSnapshotViewForViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeContentOffsetForViewController:(EPQuestionsTableViewController*)viewController;
- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeToPersistentStorage;

+ (NSString*)persistentStoreFileName;
+ (NSString*)contentOffsetKey;
+ (UIColor*)colorQuantum;
// do not call this method directly - it is here for the purpose of testing
- (BOOL)viewIsVisibleForViewController:(EPQuestionsTableViewController*)viewController;

@end
