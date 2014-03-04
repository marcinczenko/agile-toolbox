//
//  EPQuestionsTableViewExpert.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/01/14.
//
//

#import "EPQuestionsTableViewExpert.h"
#import "EPPersistentStoreHelper.h"

#import "EPQuestionsTableViewController.h"

@interface EPQuestionsTableViewExpert ()

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,readonly) CGFloat contentHeight;
@property (nonatomic,readonly) CGFloat unusedContentHeight;
@property (nonatomic,readonly) CGFloat unusedContentHeightRefreshAware;

@end

@implementation EPQuestionsTableViewExpert

+ (UIColor*)colorQuantum
{
    return [UIColor colorWithRed:0.937 green:0.255 blue:0.165 alpha:1.0];
}

+ (CGFloat)questionRowHeight
{
    return 105.0;
}

+ (CGFloat)fetchMoreRowHeight
{
    return 44.0;
}

- (id)initWithTableView:(UITableView*)tableView
{
    if ((self = [super init])) {
        _tableView = tableView;
    }
    return self;
}

- (CGFloat)contentHeight
{
    CGFloat trueContentHeight = 0;
    
    for (int i=0; i<self.tableView.numberOfSections; i++) {
        trueContentHeight += [self.tableView rectForSection:i].size.height;
    }
    
    return trueContentHeight;
}

- (CGFloat)unusedContentHeight
{
    return self.tableView.frame.size.height-self.tableView.contentInset.top-self.contentHeight;
}

- (CGFloat)unusedContentHeightRefreshAware
{
    return self.tableView.frame.size.height-self.viewController.heightOfNavigationBarAndStatusBar-self.contentHeight;
}


- (BOOL)totalContentHeightSmallerThanScreenSize
{
    return (self.contentHeight+self.tableView.contentInset.top < self.tableView.frame.size.height);
}

- (BOOL)totalContentHeightSmallerThanScreenSizeRefreshAware
{
    return (self.contentHeight+self.viewController.heightOfNavigationBarAndStatusBar < self.tableView.frame.size.height);
}

- (void)adjustTableFooterToActualContentSize
{
    if (nil!=self.tableView.tableFooterView) {
        CGRect frame = self.tableView.tableFooterView.frame;
        frame.size.height = self.unusedContentHeightRefreshAware;
        self.tableView.tableFooterView.frame = frame;
    }
}

- (void)addTableFooterWithHeight:(CGFloat)height
{
    if (nil==self.tableView.tableFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
        UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.tableView.frame.size.width-15, 0.5)];
        separatorView.backgroundColor = self.tableView.separatorColor;
        [footerView setBackgroundColor:[UIColor whiteColor]];
        [footerView addSubview:separatorView];
        [self.tableView setTableFooterView:footerView];
    }
}


- (void)addTableFooterInOrderToHideEmptyCells
{
    [self addTableFooterWithHeight:self.unusedContentHeight];
}

- (void)addRefreshAwareTableFooterInOrderToHideEmptyCells
{
    [self addTableFooterWithHeight:self.unusedContentHeightRefreshAware];
}


- (EPFetchMoreTableViewCell*)fetchMoreCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{    
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (BOOL)scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:(UIScrollView*)scrollView
{
    return (scrollView.contentOffset.y <= -100);
}

- (BOOL)scrolledToTopOrHigher
{
    return (-[self.viewController heightOfNavigationBarAndStatusBar]>=self.tableView.bounds.origin.y);
}

- (void)deleteFetchMoreCell
{
    if (self.totalContentHeightSmallerThanScreenSize) {
        if (0 == [self.tableView numberOfRowsInSection:0]) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        }
        
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)removeTableFooter
{
    [self.tableView setTableFooterView:nil];
}

@end
