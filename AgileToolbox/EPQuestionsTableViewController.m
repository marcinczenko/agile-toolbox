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

#import "EPAppDelegate.h"

#import "Question.h"

@interface EPQuestionsTableViewController ()

@property (nonatomic,assign) BOOL isLoadingData ;
@property (nonatomic,assign) BOOL lastCellIsVisible;
@property (nonatomic,readonly) CGFloat contentHeight;
@property (nonatomic,readonly) BOOL totalContentHeightSmallerThanScreenSize;
@property (nonatomic,weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,readonly) EPFetchMoreTableViewCell *fetchMoreTableViewCell;

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
    
    if (![NSThread isMainThread]) {
        NSLog(@"I am not in the MainThread");
        return;
    }
    
    self.view.accessibilityLabel = @"Questions";
    
    EPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.fetchedResultsController.delegate = self;
    self.questionsDataSource.delegate = self;
    
    if (0 == self.fetchedResultsController.fetchedObjects.count && [self.questionsDataSource hasMoreQuestionsToFetch]) {
        self.isLoadingData = YES;
        [self.questionsDataSource fetchOlderThan:-1];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.questionsDataSource = nil;
    self.postman = nil;
}

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (BOOL)shouldRespondToScrollFor:(UIScrollView*)scrollView
{
    if (self.isLoadingData) return NO;
    if (!self.lastCellIsVisible) return NO;
    if (!self.questionsDataSource.hasMoreQuestionsToFetch) return NO;
    if (![self scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView]) return NO;
    
    return YES;
}

- (EPFetchMoreTableViewCell*)fetchMoreTableViewCell
{
    return (EPFetchMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}


- (void)setFetchMoreCellFetchIndicatorStatusTo:(BOOL)status
{
    self.fetchMoreTableViewCell.label.hidden = status;
    if (status) {
        [self.fetchMoreTableViewCell.activityIndicator startAnimating];
    } else {
        [self.fetchMoreTableViewCell.activityIndicator stopAnimating];
    }
}

- (void)setFetchMoreCellFetchIndicatorStatusTo:(BOOL)status forCell:(EPFetchMoreTableViewCell*)fetchMoreTableViewCell
{
    fetchMoreTableViewCell.label.hidden = status;
    if (status) {
        [fetchMoreTableViewCell.activityIndicator startAnimating];
    } else {
        [fetchMoreTableViewCell.activityIndicator stopAnimating];
    }
}

- (void)setFetchIndicatorsStatusTo:(BOOL)status
{
    [self setFetchMoreCellFetchIndicatorStatusTo:status];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:status];
}

- (void)fetchNextSetOfQuestions
{
    Question *question = (Question*)self.fetchedResultsController.fetchedObjects.lastObject;
    [self.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self shouldRespondToScrollFor:scrollView]) {
        self.isLoadingData = YES;
        
        [self fetchNextSetOfQuestions];
        
        [self setFetchIndicatorsStatusTo:YES];
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
        if (1 == tableView.numberOfSections && 0 == self.fetchedResultsController.fetchedObjects.count) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView setTableFooterView:nil];
//                [self addTableFooterViewInOrderToHideEmptyCells];
//            });
            return 1;
        } else {
            return self.fetchedResultsController.fetchedObjects.count;
        }
    } else {
        return 1 ;
    }
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
    if (0==self.fetchedResultsController.fetchedObjects.count && self.isLoadingData) {
        [self setFetchMoreCellFetchIndicatorStatusTo:YES forCell:fetchMoreCell];
        [self addTableFooterViewInOrderToHideEmptyCells];
        
    } else {
        fetchMoreCell.label.hidden = NO;
    }
}

- (UITableViewCell*)setUpFetchMoreCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    EPFetchMoreTableViewCell *fetchMoreCell = [tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                                                              forIndexPath:indexPath];
    
    [self setUpFetchMoreCell:fetchMoreCell];
    
    return fetchMoreCell;
}

- (UITableViewCell*)setUpQuestionCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                            forIndexPath:indexPath];
    Question *question = [self.fetchedResultsController objectAtIndexPath:indexPath];
    questionCell.textLabel.text = question.content;
    
    return questionCell;
}

- (BOOL) totalContentHeightSmallerThanScreenSize
{
    return (self.contentHeight+self.tableView.contentInset.top < self.tableView.frame.size.height);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        
        if (0 == self.fetchedResultsController.fetchedObjects.count) {
            EPFetchMoreTableViewCell *fetchMoreCell = [tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                                                                      forIndexPath:indexPath];
            
            fetchMoreCell.label.text = @"No questions on the server";
            
            [self addTableFooterViewInOrderToHideEmptyCells];
            
            return fetchMoreCell;
        } else {
            if (indexPath.row == self.fetchedResultsController.fetchedObjects.count-1) {
                self.lastCellIsVisible = YES;
                
                if (self.totalContentHeightSmallerThanScreenSize) {
                    [self addTableFooterViewInOrderToHideEmptyCells];
                }
            }
            
            return [self setUpQuestionCellForTableView:tableView atIndexPath:indexPath];
        }
        
    } else {
        return [self setUpFetchMoreCellForTableView:tableView atIndexPath:indexPath];
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

- (void)deleteFetchMoreCell
{
    if (self.totalContentHeightSmallerThanScreenSize) {
        if (0 == self.fetchedResultsController.fetchedObjects.count) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        }
        
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - EPQuestionsDataSourceDelegate

- (void)fetchReturnedNoData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView beginUpdates];
    [self deleteFetchMoreCell];
    if (0 == self.fetchedResultsController.fetchedObjects.count) {
        [self.tableView setTableFooterView:nil];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    } else {
        [self.tableView endUpdates];
    }
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

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView setTableFooterView:nil];
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (NSFetchedResultsChangeInsert == type) {
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.questionsDataSource.hasMoreQuestionsToFetch) {
        [self deleteFetchMoreCell];
        [self.tableView endUpdates];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        [self.tableView endUpdates];
        [self setFetchIndicatorsStatusTo:NO];
    }
    self.isLoadingData = NO;
}

@end
