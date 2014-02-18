//
//  EPTableViewRefreshControlDelegate.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import <Foundation/Foundation.h>
@class EPTableViewRefreshControl;

@protocol EPTableViewRefreshControlDelegate <NSObject>

- (void)refresh:(UIRefreshControl*)refreshControl;

@end
