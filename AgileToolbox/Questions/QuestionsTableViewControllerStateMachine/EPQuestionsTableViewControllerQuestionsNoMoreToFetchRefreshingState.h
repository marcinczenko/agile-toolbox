//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState : EPQuestionsTableViewControllerQuestionsLoadingState

@property (nonatomic,assign) BOOL connectionFailureFlag;

- (void)handleEvent;
- (void)handleConnectionFailureUsingNativeRefreshControlCompletionHandler;
- (void)keepVisibleFor:(double)seconds completionBlock:(void (^)())block;
- (void)checkAndCancelRestoringScrollPosition;

@end
