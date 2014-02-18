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

// properties that need to be persisted
@property (nonatomic,readonly) NSURL* idOfTheFirstVisibleRow;
@property (nonatomic,strong) UIImageView* snapshotView;
@property (nonatomic,assign) CGRect bounds;
@property (nonatomic,assign) CGFloat scrollDelta;

+ (NSString*)persistentStoreFileName;
+ (NSString*)kBounds;
+ (NSString*)kScrollDelta;

+ (instancetype)restoreFromPersistentStorage;

- (void)recordCurrentStateForViewController:(EPQuestionsTableViewController*)viewController;

- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController;
- (void)createSnapshotViewForViewController:(EPQuestionsTableViewController*)viewController;
- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeToPersistentStorage;
- (void)invalidatePersistentStorage;

@end
