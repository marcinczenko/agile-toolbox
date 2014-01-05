//
//  EPQuestionsTableViewController.m
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import "EPQuestionsTableViewController.h"
#import "EPQuestionTableViewCell.h"
#import "EPAddQuestionViewController.h"
#import "EPFetchMoreTableViewCell.h"
#import "EPQuestionsDataSource.h"

@interface EPQuestionsTableViewController ()

@property (nonatomic,assign) BOOL isLoadingData ;
@property (nonatomic,assign) BOOL lastCellIsVisible;
@property (nonatomic,readonly) CGFloat contentHeight;
@property (nonatomic,readonly) BOOL totalContentHeightSmallerThanScreenSize;

@end

@implementation EPQuestionsTableViewController
@synthesize questionsDataSource = _dataSource;
@synthesize postman = _postman;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.isLoadingData = NO;
        self.lastCellIsVisible = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isLoadingData = NO;
    self.lastCellIsVisible = NO;
    
    self.view.accessibilityLabel = @"Questions";
    
    [self.questionsDataSource setDelegate:self];
    
    if (0 == self.questionsDataSource.length) {
        [self.questionsDataSource fetch];
        self.isLoadingData = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    [self.postman setDelegate:self];
    
    self.tableView.delegate = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    if ([self.view window] == nil) {
        self.view = nil;
    }
    
    self.questionsDataSource = nil;
    self.postman = nil;
}

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%d",self.lastCellIsVisible);
    if (self.questionsDataSource.hasMoreQuestionsToFetch && self.lastCellIsVisible) {
        if ([self scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView])
        {
            if (!self.isLoadingData) {
                self.isLoadingData = YES;
                [self.questionsDataSource fetch];
                [self activateFetchingIndicatorForCell:[self fetchMoreTableViewCell]];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddQuestion"]) {
        
        UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
        
        EPAddQuestionViewController* destinationVC =  (EPAddQuestionViewController*)navigationController.topViewController;
        destinationVC.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.questionsDataSource.hasMoreQuestionsToFetch ? 2 : 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return self.questionsDataSource.length;
    } else {
        return 1 ;
    }
}

- (EPFetchMoreTableViewCell*)fetchMoreTableViewCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (void)activateFetchingIndicatorForCell:(EPFetchMoreTableViewCell*)fetchMoreCell
{
    fetchMoreCell.label.hidden = YES;
    [fetchMoreCell.activityIndicator startAnimating];
}

- (void)deactivateFetchingIndicatorForCell:(EPFetchMoreTableViewCell*)fetchMoreCell
{
    [fetchMoreCell.activityIndicator stopAnimating];
    fetchMoreCell.label.hidden = NO;
}


- (void)hideSeparatorLineForCell:(EPFetchMoreTableViewCell*)fetchMoreCell
{
    fetchMoreCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, fetchMoreCell.bounds.size.width);
}

- (CGFloat)contentHeight
{
    CGFloat trueContentHeight = 0;
    
    for (int i=0; i<self.tableView.numberOfSections; i++) {
        trueContentHeight += [self.tableView rectForSection:i].size.height;
    }
    
    return trueContentHeight;
}

- (void)addTableFooterViewInOrderToHideEmptyCells
{
    if (!self.tableView.tableFooterView) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height-self.tableView.contentInset.top-self.contentHeight)];
        [footerView setBackgroundColor:[UIColor whiteColor]];
        [self.tableView setTableFooterView:footerView];
    }
}

- (void)setUpFetchMoreCell:(EPFetchMoreTableViewCell*)fetchMoreCell
{
    [self hideSeparatorLineForCell:fetchMoreCell];
    if (0==self.questionsDataSource.length && self.isLoadingData) {
        [self activateFetchingIndicatorForCell:fetchMoreCell];
        [self addTableFooterViewInOrderToHideEmptyCells];
        
    } else {
        fetchMoreCell.label.hidden = NO;
    }
    
}

- (BOOL) totalContentHeightSmallerThanScreenSize
{
    return (self.contentHeight+self.tableView.contentInset.top < self.tableView.frame.size.height);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                        forIndexPath:indexPath];
        questionCell.textLabel.text = [self.questionsDataSource questionAtIndex:indexPath.row];
        
        if (indexPath.row == self.questionsDataSource.length-1) {
            self.lastCellIsVisible = YES;
            
            if (self.totalContentHeightSmallerThanScreenSize) {
                [self addTableFooterViewInOrderToHideEmptyCells];
            }
        }
        
        return questionCell;
    } else {
        EPFetchMoreTableViewCell *fetchMoreCell = [tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                        forIndexPath:indexPath];
        
        [self setUpFetchMoreCell:fetchMoreCell];

        return fetchMoreCell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (NSArray*)indexPathsFrom:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger row=fromIndex; row<=toIndex; row++) {
        [array addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return array;
}

//- (void)animateFetchMoreCellLabelWithText:(NSString*)text
//{
//    [UIView beginAnimations:@"animateText" context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:1.0f];
//    [[self fetchMoreTableViewCell].label setAlpha:0];
//    [self fetchMoreTableViewCell].label.text = text;
//    [[self fetchMoreTableViewCell].label setAlpha:1];
//    [UIView commitAnimations];
//}

//- (void)removeFetchMoreSection
//{
//    int64_t delayInSeconds = 1.0f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.tableView beginUpdates];
//        
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//        
//        [self.tableView endUpdates];
//    });
//}

- (void)insertRows:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    [self.tableView insertRowsAtIndexPaths:[self indexPathsFrom:fromIndex to:toIndex] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteFetchMoreCell
{
    if (self.totalContentHeightSmallerThanScreenSize) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)updateTableViewRowsFrom:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    [self.tableView beginUpdates];
    
    [self insertRows:fromIndex to:toIndex];
    
    if (!self.questionsDataSource.hasMoreQuestionsToFetch) {
        [self deleteFetchMoreCell];
    }
    
    [self.tableView endUpdates];
}

#pragma mark - EPQuestionsDataSourceDelegate
- (void)questionsFetchedFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.tableView setTableFooterView:nil];
        [self deactivateFetchingIndicatorForCell:[self fetchMoreTableViewCell]];
        [self updateTableViewRowsFrom:fromIndex to:toIndex];
        self.isLoadingData = NO;
    });
}

#pragma mark - EPAddQuestionDelegateProtocol
- (void)questionAdded:(NSString *)question
{
    [self.postman post:question];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - EPPostmanDelegateProtocol
- (void)postDelivered
{
    [self.questionsDataSource fetchNew];
}

// TODO: not yet supported
- (void)postDeliveryFailed
{
    
}


@end
