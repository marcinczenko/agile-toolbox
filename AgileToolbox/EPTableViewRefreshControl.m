//
//  EPTableViewRefreshControl.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import "EPTableViewRefreshControl.h"

@interface EPTableViewRefreshControl ()

@property (nonatomic,weak) UIRefreshControl* uiRefreshControl;
@property (nonatomic,weak) UITableViewController* tableViewController;
@property (nonatomic,strong) NSDictionary* titleAttributes;

@property (nonatomic,copy) EPTableViewRefreshControlRefreshBlockType refreshBlock;

@end

@implementation EPTableViewRefreshControl

@synthesize title = _title;

- (NSAttributedString*)attributedTitle
{
    return self.uiRefreshControl.attributedTitle;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    self.uiRefreshControl.attributedTitle = attributedTitle;
    _titleAttributes = [attributedTitle attributesAtIndex:0 effectiveRange:nil];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.uiRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:_title attributes:_titleAttributes];
}

- (NSString*)title
{
    return self.uiRefreshControl.attributedTitle.string;
}

//- (UIRefreshControl*)uiRefreshControl
//{
//    if (!_uiRefreshControl) {
//        _uiRefreshControl = [[UIRefreshControl alloc] init];
//        _uiRefreshControl.attributedTitle = [[NSAttributedString alloc] init];
//        [_uiRefreshControl addTarget:self
//                              action:@selector(refresh:)
//                    forControlEvents:UIControlEventValueChanged];
//        _tableViewController.refreshControl = _uiRefreshControl;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_tableViewController.refreshControl beginRefreshing];
//            [_tableViewController.refreshControl endRefreshing];
//        });
//    } else {
//        if (!_tableViewController.refreshControl) {
//            _uiRefreshControl = [[UIRefreshControl alloc] init];
//            _uiRefreshControl.attributedTitle = [[NSAttributedString alloc] init];
//            [_uiRefreshControl addTarget:self
//                                  action:@selector(refresh:)
//                        forControlEvents:UIControlEventValueChanged];
//            _tableViewController.refreshControl = _uiRefreshControl;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_tableViewController.refreshControl beginRefreshing];
//                [_tableViewController.refreshControl endRefreshing];
//            });
//        }
//    }
//    
//    return _uiRefreshControl;
//}

- (UIRefreshControl*)uiRefreshControl
{
    if (!_tableViewController.refreshControl) {
        _uiRefreshControl = [[UIRefreshControl alloc] init];
        _uiRefreshControl.attributedTitle = [[NSAttributedString alloc] init];
        [_uiRefreshControl addTarget:self
                              action:@selector(refresh:)
                    forControlEvents:UIControlEventValueChanged];
        _tableViewController.refreshControl = _uiRefreshControl;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewController.refreshControl beginRefreshing];
            [_tableViewController.refreshControl endRefreshing];
        });
    }
    return _uiRefreshControl;
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
    return self.uiRefreshControl.isRefreshing;
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

- (void)beginRefreshingWithBeforeBlock:(void(^)())beforeBlock afterBlock:(void(^)())afterBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (beforeBlock) {
            beforeBlock();
        }
        
        [self.uiRefreshControl beginRefreshing];
        
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
        [self.uiRefreshControl beginRefreshing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uiRefreshControl endRefreshing];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self beforeBeginRefreshing];
                
                [self.uiRefreshControl beginRefreshing];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self afterBeginRefreshing];
                });
                
            });
        });
    });
}

- (void)endRefreshing
{
    [self.uiRefreshControl endRefreshing];
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
        self.refreshBlock(self);
    }    
    if ([self.delegate respondsToSelector:@selector(refresh:)]) {
        [self.delegate refresh:self];
    }
}

@end
