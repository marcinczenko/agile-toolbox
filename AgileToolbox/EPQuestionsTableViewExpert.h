//
//  EPQuestionsTableViewExpert.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPFetchMoreTableViewCell.h"

@interface EPQuestionsTableViewExpert : NSObject

@property (nonatomic,readonly) UITableView *tableView;
@property (nonatomic,readonly) EPFetchMoreTableViewCell* fetchMoreCell;

- (id)initWithTableView:(UITableView*)tableView;
- (void)addTableFooterInOrderToHideEmptyCells;
- (BOOL)totalContentHeightSmallerThanScreenSize;
- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView;
- (BOOL)scrollPositionTriggersFetchingWhenContentSizeSmallerThanThanScreenSizeForScrollView:(UIScrollView*)scrollView;
- (void)deleteFetchMoreCell;
- (void)removeTableFooter;

@end
