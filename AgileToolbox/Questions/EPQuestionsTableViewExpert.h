//
//  EPQuestionsTableViewExpert.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPFetchMoreTableViewCell.h"
#import "EPQuestionTableViewCell.h"

@class EPQuestionsTableViewController;

@interface EPQuestionsTableViewExpert : NSObject

@property (nonatomic,weak) EPQuestionsTableViewController* viewController;
@property (nonatomic,readonly) UITableView *tableView;
@property (nonatomic,readonly) EPFetchMoreTableViewCell* fetchMoreCell;
@property (nonatomic,readonly) EPFetchMoreTableViewCell* refreshStatusCell;

@property (nonatomic,strong) UIView* refreshControl;

+ (CGFloat)questionRowHeight;
+ (CGFloat)fetchMoreRowHeight;
+ (UIColor*)colorQuantum;

- (id)initWithTableView:(UITableView*)tableView;
- (void)addTableFooterInOrderToHideEmptyCells;
- (BOOL)totalContentHeightSmallerThanScreenSize;
- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView;
- (BOOL)scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:(UIScrollView*)scrollView;
- (void)deleteFetchMoreCell;
- (void)removeTableFooter;
- (UIImageView*)createSnapshotView;

@end
