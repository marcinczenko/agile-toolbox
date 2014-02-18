//
//  EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 10/02/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"

@interface EPQuestionsTableViewControllerQuestionsNoMoreToFetchRefreshingState : EPQuestionsTableViewControllerQuestionsLoadingState

@property (nonatomic,strong) UILabel* label;

- (void)handleEvent;
- (void)handleConnectionFailureUsingNativeRefreshControlCompletionHandler;

@end
