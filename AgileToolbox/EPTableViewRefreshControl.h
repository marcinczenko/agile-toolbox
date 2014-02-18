//
//  EPTableViewRefreshControl.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import <UIKit/UIKit.h>
#import "EPTableViewRefreshControlDelegate.h"

@interface EPTableViewRefreshControl : NSObject

typedef void (^EPTableViewRefreshControlRefreshBlockType)(id refreshControl);

@property (nonatomic) NSAttributedString* attributedTitle;
@property (nonatomic,copy) NSString* title;
@property (nonatomic,readonly) BOOL isRefreshing;
@property (nonatomic,weak) id<EPTableViewRefreshControlDelegate> delegate;
//@property (nonatomic,readonly) UIRefreshControl* uiRefreshControl;
@property (nonatomic,readonly) UITableViewController* tableViewController;

- (instancetype)initWithTableViewController:(UITableViewController*)tableViewController;
- (instancetype)initWithTableViewController:(UITableViewController*)tableViewController
                               refreshBlock:(EPTableViewRefreshControlRefreshBlockType)block;

- (void)beginRefreshingWithTitle:(NSString*)title;
- (void)endRefreshingWithTitle:(NSString*)title;
- (void)beginRefreshing;
- (void)beginRefreshingWithBeforeBlock:(void(^)())beforeBlock afterBlock:(void(^)())afterBlock;
- (void)endRefreshing;

// begin refreshing hooks
- (void)beforeBeginRefreshing;
- (void)afterBeginRefreshing;

// do not call - only for testing
- (void)refresh:(UIRefreshControl*)refreshControl;

@end
