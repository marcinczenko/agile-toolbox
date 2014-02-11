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

@interface EPQuestionsTableViewExpert : NSObject

@property (nonatomic,readonly) UITableView *tableView;
@property (nonatomic,readonly) EPFetchMoreTableViewCell* fetchMoreCell;
@property (nonatomic,readonly) EPFetchMoreTableViewCell* refreshStatusCell;

+ (UIColor*)colorQuantum;

- (id)initWithTableView:(UITableView*)tableView;
- (void)addTableFooterInOrderToHideEmptyCells;
- (BOOL)totalContentHeightSmallerThanScreenSize;
- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView;
- (BOOL)scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:(UIScrollView*)scrollView;
- (void)deleteFetchMoreCell;
- (void)deleteRefreshingStatusCell;
- (void)removeRefreshStatusCellFromScreen;
- (void)removeTableFooter;
- (UIImageView*)createSnapshotView;

@end
