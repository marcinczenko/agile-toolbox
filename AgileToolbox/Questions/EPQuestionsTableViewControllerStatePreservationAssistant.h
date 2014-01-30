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

+ (instancetype)restoreFromPersistentStorage;

- (void)viewController:(EPQuestionsTableViewController*)viewController didEnterBackgroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController willEnterForegroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController didBecomeActiveNotification:(NSNotification*)notification;
- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeToPersistentStorageForViewController:(EPQuestionsTableViewController*)viewController;
- (NSIndexPath*)indexPathForQuestionURI:(NSURL*)uri inViewController:(EPQuestionsTableViewController*)viewController;

+ (NSString*)persistentStoreFileName;
// do not call this method directly - it is here for the purpose of testing
- (BOOL)viewIsVisibleForViewController:(EPQuestionsTableViewController*)viewController;

@end
