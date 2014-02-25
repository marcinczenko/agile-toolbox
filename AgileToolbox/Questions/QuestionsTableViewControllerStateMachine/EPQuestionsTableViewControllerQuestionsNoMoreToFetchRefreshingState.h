//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerEmptyLoadingState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState : EPQuestionsTableViewControllerEmptyLoadingState

@property (nonatomic,assign) BOOL connectionFailurePending;

- (void)handleEvent;
- (void)handleConnectionFailureUsingNativeRefreshControl;
- (void)handleConnectionFailureUsingNativeRefreshControlCompletionHandler;
- (void)keepVisibleFor:(double)seconds completionBlock:(void (^)())block;
- (void)checkAndCancelRestoringScrollPosition;

@end
