//
//  EPQuestionsTableViewControllerInitialState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 23/01/14.
//
//

#import "EPQuestionsTableViewControllerInitialState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

@implementation EPQuestionsTableViewControllerInitialState

- (void)viewDidLoad
{
    if (!self.viewController.hasQuestionsInPersistentStorage) {
        if ([self.viewController.questionsDataSource hasMoreQuestionsToFetch]) {
            [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
            [self.viewController.questionsDataSource fetchOlderThan:-1];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        else {
            [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
        }
    } else {
        [self.viewController setupRefreshControl];
        if ([self.viewController.questionsDataSource hasMoreQuestionsToFetch]) {
            [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
        }
        else {
            [self.stateMachine changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
        }
    }
}

@end
