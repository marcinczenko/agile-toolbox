//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState : EPQuestionsTableViewControllerQuestionsLoadingState

- (void)handleEvent;
- (void)handleConnectionFailureUsingRefreshStatusCell;
- (void)handleConnectionFailureUsingNativeRefreshControl;
- (void)handleConnectionFailureUsingNativeRefreshControlCompletion;
- (void)handleConnectionFailureUsingRefreshStatusCellCompletion;

@end
