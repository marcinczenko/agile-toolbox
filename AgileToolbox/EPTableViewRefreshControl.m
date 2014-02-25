//
//  EPTableViewRefreshControl.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import "EPTableViewRefreshControl.h"

@interface EPTableViewRefreshControl ()

@property (nonatomic,weak) UITableViewController* tableViewController;
@property (nonatomic,strong) NSDictionary* titleAttributes;

@property (nonatomic,copy) EPTableViewRefreshControlRefreshBlockType refreshBlock;

@end

@implementation EPTableViewRefreshControl

@synthesize title = _title;

- (NSAttributedString*)attributedTitle
{
    return self.tableViewController.refreshControl.attributedTitle;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    [self initRefreshControlWithText:attributedTitle];
    _titleAttributes = [attributedTitle attributesAtIndex:0 effectiveRange:nil];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [self initRefreshControlWithText:[[NSAttributedString alloc] initWithString:_title attributes:_titleAttributes]];
}

- (NSString*)title
{
    return self.tableViewController.refreshControl.attributedTitle.string;
}

- (void)initializationHackHook
{
    [self.tableViewController.refreshControl beginRefreshing];
    [self.tableViewController.refreshControl endRefreshing];
}

- (void)initRefreshControlWithText:(NSAttributedString*)attributedString
{
    if (!self.tableViewController.refreshControl) {
        UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = attributedString;
        [refreshControl addTarget:self
                           action:@selector(refresh:)
                 forControlEvents:UIControlEventValueChanged];
        self.tableViewController.refreshControl = refreshControl;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializationHackHook];
        });
    } else {
        self.tableViewController.refreshControl.attributedTitle = attributedString;
    }
    
}

- (instancetype)initWithTableViewController:(UITableViewController*)tableViewController
{
    return [self initWithTableViewController:tableViewController refreshBlock:nil];
}

- (instancetype)initWithTableViewController:(UITableViewController*)tableViewController
                               refreshBlock:(EPTableViewRefreshControlRefreshBlockType)block
{
    self = [super init];
    
    if (self) {
        _tableViewController = tableViewController;
        _refreshBlock = block;
    }
    return self;
}

- (BOOL)isRefreshing
{
    return self.tableViewController.refreshControl.isRefreshing;
}

- (void)beginRefreshingWithTitle:(NSString*)title
{
    self.title = title;
    
    [self beginRefreshing];    
}

- (void)endRefreshingWithTitle:(NSString*)title
{
    [self endRefreshing];
    self.title = title;
}

- (void)adjustContentOffsetToRevealRefreshControl
{
    // This is - again - hack. We should not need doing it,
    // but if we don't, the refresh control will be enabled
    // but the text below will remain invisible.
    self.tableViewController.tableView.contentOffset = CGPointMake(0, -self.tableViewController.tableView.contentInset.top-self.tableViewController.refreshControl.frame.size.height);
}

- (void)beginRefreshingWithBeforeBlock:(void(^)())beforeBlock afterBlock:(void(^)())afterBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (beforeBlock) {
            beforeBlock();
        }
        
        [self adjustContentOffsetToRevealRefreshControl];
        
        [self.tableViewController.refreshControl beginRefreshing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (afterBlock) {
                afterBlock();
            }
        });
        
    });
}

- (void)beginRefreshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewController.refreshControl beginRefreshing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewController.refreshControl endRefreshing];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self beforeBeginRefreshing];
                
                [self.tableViewController.refreshControl beginRefreshing];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self afterBeginRefreshing];
                });
                
            });
        });
    });
}

- (void)endRefreshing
{
    [self.tableViewController.refreshControl endRefreshing];
}

- (void)beforeBeginRefreshing
{
    
}

- (void)afterBeginRefreshing
{

}

- (void)refresh:(UIRefreshControl*)refreshControl
{
    if (self.refreshBlock) {
        self.refreshBlock(self.tableViewController.refreshControl);
    }    
    if ([self.delegate respondsToSelector:@selector(refresh:)]) {
        [self.delegate refresh:self.tableViewController.refreshControl];
    }
}

@end
