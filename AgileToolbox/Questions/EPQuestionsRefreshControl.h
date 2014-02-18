//
//  EPQuestionsRefreshControl.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import "EPTableViewRefreshControl.h"

extern NSString* const EPQuestionsRefreshControlTextBeginRefreshing;
extern NSString* const EPQuestionsRefreshControlTextEnabled;
extern NSString* const EPQuestionsRefreshControlTextConnectionFailure;


@interface EPQuestionsRefreshControl : EPTableViewRefreshControl

- (void)enable;

@end
