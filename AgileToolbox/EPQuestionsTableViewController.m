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

#import "EPQuestionsTableViewControllerState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"

#import "EPAppDelegate.h"

#import "Question.h"

@interface EPQuestionsTableViewController ()

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
    }
    return self;
}

- (BOOL)noQuestionsOnTheScreen
{
    return (0 == self.fetchedResultsController.fetchedObjects.count);
}

- (EPQuestionsTableViewControllerState*)getEntryState
{
    if ([self noQuestionsOnTheScreen]) {
        if ([self.questionsDataSource hasMoreQuestionsToFetch]) {
            return [EPQuestionsTableViewControllerEmptyLoadingState instance];
        }
        else {
            return [EPQuestionsTableViewControllerEmptyNoQuestionsState instance];
        }
    } else {
        if ([self.questionsDataSource hasMoreQuestionsToFetch]) {
            return [EPQuestionsTableViewControllerQuestionsWithFetchMoreState instance];
        }
        else {
            return [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState instance];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityLabel = @"Questions";
    
    EPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.fetchedResultsController.delegate = self;
    self.questionsDataSource.delegate = self;
    [self.postman setDelegate:self];
    self.tableView.delegate = self;
    
    self.state = [self getEntryState];
    
    [self.state viewDidLoad:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)didReceiveMemoryWarning
{
    if ([self.view window] == nil) {
        self.view = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.questionsDataSource = nil;
    self.postman = nil;
}

//--------------------------------------------------------------
// Calculations

- (BOOL)scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:(UIScrollView*)scrollView
{
    return ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height+50);
}

- (CGFloat)contentHeight
{
    CGFloat trueContentHeight = 0;
    
    for (int i=0; i<self.tableView.numberOfSections; i++) {
        trueContentHeight += [self.tableView rectForSection:i].size.height;
    }
    
    return trueContentHeight;
}

- (BOOL) totalContentHeightSmallerThanScreenSize
{
    return (self.contentHeight+self.tableView.contentInset.top < self.tableView.frame.size.height);
}


- (void)fetchNextSetOfQuestions
{
    Question *question = (Question*)self.fetchedResultsController.fetchedObjects.lastObject;
    [self.questionsDataSource fetchOlderThan:question.question_id.integerValue];
}

- (UITableViewCell*)setUpQuestionCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                            forIndexPath:indexPath];
    Question *question = [self.fetchedResultsController objectAtIndexPath:indexPath];
    questionCell.textLabel.text = question.content;
    
    return questionCell;
}

- (void)deleteFetchMoreCell
{
    if (self.totalContentHeightSmallerThanScreenSize) {
        if ([self noQuestionsOnTheScreen]) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        }
        
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
}


#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.state viewController:self scrollViewDidScroll:scrollView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.state numberOfSectionsInTableView:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.state viewController:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.state viewController:self cellForRowAtIndexPath:indexPath];
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

#pragma mark - EPQuestionsDataSourceDelegate

- (void)fetchReturnedNoData
{
    [self.state fetchReturnedNoData:self];
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
    [self.state controllerDidChangeContent:self];
}

@end
