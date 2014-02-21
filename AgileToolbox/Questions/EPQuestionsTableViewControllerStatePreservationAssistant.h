//
//  EPQuestionsTableViewControllerStatePreservationAssistant.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 27/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPSnapshot.h"
@class EPQuestionsTableViewController;

@interface EPQuestionsTableViewControllerStatePreservationAssistant : NSObject<NSCoding>

@property (nonatomic,assign) BOOL viewNeedsRefreshing;

// properties that need to be persisted
// EPQuestionsTableViewController
@property (nonatomic,readonly) NSURL* idOfTheFirstVisibleRow;
@property (nonatomic,readonly) EPSnapshot* snapshot;
@property (nonatomic,assign) CGRect bounds;
@property (nonatomic,assign) CGFloat scrollDelta;
// // EPAddQuestionTableViewController
@property (nonatomic,assign) NSRange selectedRange;
@property (nonatomic,assign) BOOL isContentViewFirstResponder;
@property (nonatomic,strong) NSString* addQuestionViewHeaderText;
@property (nonatomic,strong) NSString* addQuestionViewContentText;
@property (nonatomic,assign) CGFloat addQuestionContentCellHeight;
@property (nonatomic,assign) CGPoint addQuestionTableViewContentOffset;


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
