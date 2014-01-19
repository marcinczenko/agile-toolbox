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

- (id)initWithTableView:(UITableView*)tableView
{
    if ((self = [super self])) {
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
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.unusedContentHeight)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setTableFooterView:footerView];
}

- (EPFetchMoreTableViewCell*)fetchMoreCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

//- (UITableViewCell*)setUpQuestionCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
//{
//    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
//                                                                            forIndexPath:indexPath];
//    Question *question = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    questionCell.textLabel.text = question.content;
//    
//    return questionCell;
//}

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
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
