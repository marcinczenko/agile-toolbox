//
//  EPQuestionsTableViewControllerState.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPQuestionsTableViewController.h"

@interface EPQuestionsTableViewControllerState : NSObject

+ (id)instance;

- (void)addTableFooterViewInOrderToHideEmptyCellsIn:(EPQuestionsTableViewController*)viewController;

- (void)viewDidLoad:(EPQuestionsTableViewController*)viewController;
- (void)controllerDidChangeContent:(EPQuestionsTableViewController*)viewController;
- (UITableViewCell*)viewController:(EPQuestionsTableViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)viewController:(EPQuestionsTableViewController*)viewController scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fetchReturnedNoData:(EPQuestionsTableViewController*)viewController;
- (NSInteger)viewController:(EPQuestionsTableViewController*)viewController numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(EPQuestionsTableViewController*)viewController;

@end
