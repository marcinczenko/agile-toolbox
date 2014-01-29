//
//  EPQuestionsTableViewControllerStatePreservationAssistant.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 27/01/14.
//
//

#import <Foundation/Foundation.h>
@class EPQuestionsTableViewController;

@interface EPQuestionsTableViewControllerStatePreservationAssistant : NSObject

typedef void (^NotificationHandlerBlockType)(NSNotification* note);

@property (nonatomic,copy,readonly) NotificationHandlerBlockType willEnterForegroundNotificationBlock;
@property (nonatomic,copy,readonly) NotificationHandlerBlockType didBecomeActiveNotificationBlock;

@property (nonatomic,readonly) NSNotificationCenter* notificationCenter;
@property (nonatomic,weak) EPQuestionsTableViewController* viewController;
@property (nonatomic,readonly) BOOL viewNeedsRefreshing;
@property (nonatomic,readonly) NSNumber* idOfTheFirstVisibleRow;

- (instancetype)init;

- (void)viewController:(EPQuestionsTableViewController*)viewController didEnterBackgroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController willEnterForegroundNotification:(NSNotification*)notification;
- (void)viewController:(EPQuestionsTableViewController*)viewController didBecomeActiveNotification:(NSNotification*)notification;
- (void)storeQuestionIdOfFirstVisibleQuestionForViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreIndexPathOfFirstVisibleRowForViewController:(EPQuestionsTableViewController*)viewController;
- (void)storeToPersistentStorageForViewController:(EPQuestionsTableViewController*)viewController;
- (NSIndexPath*)indexPathForQuestionId:(NSNumber*)id inViewController:(EPQuestionsTableViewController*)viewController;
- (void)restoreFromPersistentStorage;

+ (NSString*)persistentStoreFileName;
// do not call this method directly - it is here for the purpose of testing
- (BOOL)viewIsVisibleForViewController:(EPQuestionsTableViewController*)viewController;

@end
