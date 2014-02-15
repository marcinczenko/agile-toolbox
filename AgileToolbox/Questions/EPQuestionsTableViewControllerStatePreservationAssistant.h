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

@property (nonatomic,assign) BOOL viewNeedsRefreshing;
@property (nonatomic,readonly) NSURL* idOfTheFirstVisibleRow;

@property (nonatomic,strong) UIImageView* snapshotView;
@property (nonatomic,assign) CGPoint contentOffset;
@property (nonatomic,assign) CGRect bounds;
@property (nonatomic,assign) CGFloat firstVisibleRowDistanceFromBoundsOrigin;
@property (nonatomic,assign) CGFloat refreshControllHeight;

@property (nonatomic,assign) BOOL skipTableViewScrollPositionRestoration;

+ (NSString*)persistentStoreFileName;
+ (NSString*)contentOffsetKey;

+ (instancetype)restoreFromPersistentStorage;

- (void)recordCurrentStateForViewController:(EPQuestionsTableViewController*)viewController;

- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController;
- (void)createSnapshotViewForViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeContentOffsetForViewController:(EPQuestionsTableViewController*)viewController;
- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeToPersistentStorage;

@end
