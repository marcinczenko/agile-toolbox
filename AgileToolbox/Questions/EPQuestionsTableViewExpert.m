//
//  EPQuestionsTableViewExpert.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/01/14.
//
//

#import "EPQuestionsTableViewExpert.h"
//#import "EPQuestionTableViewCell.h"

@interface EPQuestionsTableViewExpert ()

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,readonly) CGFloat contentHeight;
@property (nonatomic,readonly) CGFloat unusedContentHeight;

@end

@implementation EPQuestionsTableViewExpert

+ (UIColor*)colorQuantum
{
    return [UIColor colorWithRed:0.937 green:0.255 blue:0.165 alpha:1.0];
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

- (BOOL)totalContentHeightSmallerThanScreenSize
{
    return (self.contentHeight+self.tableView.contentInset.top < self.tableView.frame.size.height);
}

- (void)addTableFooterInOrderToHideEmptyCells
{
    if (nil==self.tableView.tableFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.unusedContentHeight)];
        [footerView setBackgroundColor:[UIColor whiteColor]];
        [self.tableView setTableFooterView:footerView];
    }
}

- (EPFetchMoreTableViewCell*)fetchMoreCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (EPFetchMoreTableViewCell*)refreshStatusCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}


- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{    
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (BOOL)scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:(UIScrollView*)scrollView
{
    return (scrollView.contentOffset.y <= -100);
}

- (UIImageView*)createSnapshotView
{
    CGRect frame = self.tableView.frame;
    
    frame.origin.y = self.tableView.contentInset.top;
    frame.size.height = frame.size.height - frame.origin.y;
    
    UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, YES, 0);
    [self.tableView drawViewHierarchyInRect: self.tableView.frame afterScreenUpdates:NO];
    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    [im drawAtPoint:CGPointMake(0, -self.tableView.contentInset.top)];
    UIImage* im2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:im2];
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

- (void)deleteRefreshingStatusCell
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)removeRefreshStatusCellFromScreen
{
    if ([EPFetchMoreTableViewCell class] == self.refreshStatusCell.class) {
        [self.tableView beginUpdates];
        [self deleteRefreshingStatusCell];
        [self removeTableFooter];
        [self.tableView endUpdates];
        if (self.totalContentHeightSmallerThanScreenSize) {
            [self addTableFooterInOrderToHideEmptyCells];
        }
    }
}

- (void)removeTableFooter
{
    [self.tableView setTableFooterView:nil];
}

@end
