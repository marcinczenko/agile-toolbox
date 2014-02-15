//
//  EPQuestionsTableViewExpert.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/01/14.
//
//

#import "EPQuestionsTableViewExpert.h"
//#import "EPQuestionTableViewCell.h"
#import "EPPersistentStoreHelper.h"

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
    UIImage* snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    [snapshot drawAtPoint:CGPointMake(0, -self.tableView.contentInset.top)];
    UIImage* croppedSnapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // we take the snapshot in local coordinates
    // but we position it using external frame:
    // if bounds = {0,100,320,568}
    // than top left visible corner will be {0,0} using local coordinates but
    // {0,100} in external coordinates.
//    CGRect imageRect = frame;
//    imageRect.origin.y += self.tableView.bounds.origin.y;
//    UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageRect];
//    imageView.image = croppedSnapshot;
//    
//    return imageView;
    return [[UIImageView alloc] initWithImage:croppedSnapshot];
}

//- (UIImageView*)createSnapshotView
//{
//    CGRect frame = self.tableView.frame;
//    CGRect bounds = self.tableView.bounds;
//    
//    NSLog(@"createSnapshotView[frame]:%@",NSStringFromCGRect(frame));
//    NSLog(@"createSnapshotView[frame]:%@",NSStringFromCGRect(bounds));
//    
//    frame.origin.y = self.tableView.contentInset.top;
//    frame.size.height = frame.size.height - frame.origin.y;
//    bounds.size.height = bounds.size.height - self.tableView.contentInset.top;
//    NSLog(@"createSnapshotView[frame]-A:%@",NSStringFromCGRect(frame));
//    NSLog(@"createSnapshotView[frame]-A:%@",NSStringFromCGRect(bounds));
//    
////    2014-02-15 16:36:54.237 AgileToolbox[929:70b] createSnapshotView[frame]:{{0, 0}, {320, 568}}
////    2014-02-15 16:36:54.237 AgileToolbox[929:70b] createSnapshotView[frame]:{{0, 3676}, {320, 568}}
////    2014-02-15 16:36:54.238 AgileToolbox[929:70b] createSnapshotView[frame]-A:{{0, 64}, {320, 504}}
////    2014-02-15 16:36:54.238 AgileToolbox[929:70b] createSnapshotView[frame]-A:{{0, 3676}, {320, 504}}
//    
//    UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, YES, 0);
//    [self.tableView drawViewHierarchyInRect: self.tableView.frame afterScreenUpdates:NO];
//    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIGraphicsBeginImageContextWithOptions(self.tableView.bounds.size, YES, 0);
//    [self.tableView drawViewHierarchyInRect: self.tableView.bounds afterScreenUpdates:NO];
//    UIImage* imb = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
//    [im drawAtPoint:CGPointMake(0, -self.tableView.contentInset.top)];
//    UIImage* im2 = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0);
//    [imb drawAtPoint:CGPointMake(0, -self.tableView.contentInset.top)];
//    UIImage* imb2 = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    NSData* imageData = UIImageJPEGRepresentation(im, 1.0);
//    
//    NSURL* path = [EPPersistentStoreHelper persistentStateURLForFile:@"im.jpg"];
//    
//    [imageData writeToFile:path.path atomically:NO];
//    
//    imageData = UIImageJPEGRepresentation(imb, 1.0);
//    
//    path = [EPPersistentStoreHelper persistentStateURLForFile:@"imb.jpg"];
//    
//    [imageData writeToFile:path.path atomically:NO];
//    
//    imageData = UIImageJPEGRepresentation(im2, 1.0);
//    
//    path = [EPPersistentStoreHelper persistentStateURLForFile:@"im2.jpg"];
//    
//    [imageData writeToFile:path.path atomically:NO];
//    
//    imageData = UIImageJPEGRepresentation(imb2, 1.0);
//    
//    path = [EPPersistentStoreHelper persistentStateURLForFile:@"imb2.jpg"];
//    
//    [imageData writeToFile:path.path atomically:NO];
//    
//    return [[UIImageView alloc] initWithImage:im2];
//}


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
    [self.tableView beginUpdates];
    [self deleteRefreshingStatusCell];
    [self removeTableFooter];
    [self.tableView endUpdates];
    if (self.totalContentHeightSmallerThanScreenSize) {
        [self addTableFooterInOrderToHideEmptyCells];
    }
}

- (void)removeTableFooter
{
    [self.tableView setTableFooterView:nil];
}

@end
