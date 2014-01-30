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

@property (nonatomic,weak) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,weak) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,weak) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,weak) id<EPPostmanProtocol> postman;
@property (nonatomic,weak) EPQuestionsTableViewControllerStateMachine *stateMachine;

@property (nonatomic,strong) EPQuestionsTableViewExpert *tableViewExpert;
@property (nonatomic,weak) EPQuestionsTableViewControllerStatePreservationAssistant* statePreservationAssistant;

@property (nonatomic,assign) BOOL isScrolling;
@property (nonatomic,assign) BOOL viewNeedsRefreshing;

@end

@implementation EPQuestionsTableViewController
@synthesize questionsDataSource = _dataSource;
@synthesize postman = _postman;

- (void)setDelegates
{
    self.fetchedResultsController.delegate = self;
    self.questionsDataSource.delegate = self;
    [self.postman setDelegate:self];
    self.tableView.delegate = self;
}

- (void)configureNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [center addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [center addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
}

- (void)injectDependenciesFrom:(EPDependencyBox*)dependencyBox
{
    self.fetchedResultsController = dependencyBox[@"FetchedResultsController"];
    self.questionsDataSource = (id<EPQuestionsDataSourceProtocol>)dependencyBox[@"DataSource"];
    self.stateMachine = (EPQuestionsTableViewControllerStateMachine*)dependencyBox[@"StateMachine"];
    self.postman = (id<EPPostmanProtocol>)dependencyBox[@"Postman"];
    self.statePreservationAssistant = (EPQuestionsTableViewControllerStatePreservationAssistant*)dependencyBox[@"StatePreservationAssistant"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityLabel = @"Questions";
    
    EPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self setDelegates];
    
    self.tableViewExpert = [[EPQuestionsTableViewExpert alloc] initWithTableView:self.tableView];
    
    [self.stateMachine assignViewController:self andTableViewExpert:self.tableViewExpert];
    
    [self.stateMachine viewDidLoad];
    
    [self configureNotifications];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didEnterBackgroundNotification:(NSNotification*)paramNotification
{
    [self.statePreservationAssistant viewController:self didEnterBackgroundNotification:paramNotification];
}

- (void)willEnterForegroundNotification:(NSNotification*)paramNotification
{
    [self.statePreservationAssistant viewController:self willEnterForegroundNotification:paramNotification];
}

- (void)didBecomeActiveNotification:(NSNotification*)paramNotification
{
    [self.statePreservationAssistant viewController:self didBecomeActiveNotification:paramNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.statePreservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.statePreservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self];
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
    
    self.tableViewExpert = nil;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isScrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isScrolling) return;
    
    if ([self.tableViewExpert scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollView]) {
        self.isScrolling = NO;
        [self.stateMachine scrollViewDidScroll:scrollView];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.stateMachine numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stateMachine numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.stateMachine cellForRowAtIndexPath:indexPath];
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
    [self.stateMachine fetchReturnedNoData];
}

- (void)fetchReturnedNoDataInBackground
{
    [self.stateMachine fetchReturnedNoDataInBackground];
}

- (void)dataChangedInBackground
{
    [self.stateMachine dataChangedInBackground];
}

- (void)connectionFailure
{
    [self.stateMachine connectionFailure];
}

- (void)connectionFailureInBackground
{
    [self.stateMachine connectionFailureInBackground];
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
    [self.tableViewExpert removeTableFooter];
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (NSFetchedResultsChangeInsert == type) {
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.stateMachine controllerDidChangeContent];
}

@end
