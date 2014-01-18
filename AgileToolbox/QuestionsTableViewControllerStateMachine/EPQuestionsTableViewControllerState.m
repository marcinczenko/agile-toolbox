//
//  EPQuestionsTableViewControllerState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsTableViewControllerStateMachine.h"

@implementation EPQuestionsTableViewControllerState

+ (id)instance
{
    static EPQuestionsTableViewControllerState *instance = nil;
    
    if (nil == instance) {
        instance = [[EPQuestionsTableViewControllerState alloc] init];
    }
    return instance;
}

- (void)addTableFooterViewInOrderToHideEmptyCellsIn:(EPQuestionsTableViewController*)viewController
{
    if (!viewController.tableView.tableFooterView) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewController.tableView.frame.size.width, viewController.tableView.frame.size.height-viewController.tableView.contentInset.top-viewController.contentHeight)];
        [footerView setBackgroundColor:[UIColor whiteColor]];
        [viewController.tableView setTableFooterView:footerView];
    }
}


- (void)viewDidLoad:(EPQuestionsTableViewController*)viewController
{
    
}

- (void)controllerDidChangeContent:(EPQuestionsTableViewController*)viewController
{
    
}

- (void)fetchReturnedNoData:(EPQuestionsTableViewController*)viewController
{
    
}

- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)viewController:(EPQuestionsTableViewController*)viewController scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(EPQuestionsTableViewController*)viewController
{
    return 1;
}

@end
