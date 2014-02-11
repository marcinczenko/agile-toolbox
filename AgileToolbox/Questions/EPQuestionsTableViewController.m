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

@property (nonatomic,assign) UIEdgeInsets contentInset;
@property (nonatomic,strong) UIImage* navBarSnapshot;
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
    
    [center addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
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

- (void)willResignActiveNotification:(NSNotification*)paramNotification
{
    [self.stateMachine willResignActiveNotification:paramNotification];
}

- (void)didEnterBackgroundNotification:(NSNotification*)paramNotification
{
    [self.stateMachine didEnterBackgroundNotification:paramNotification];
}

- (void)willEnterForegroundNotification:(NSNotification*)paramNotification
{
    [self.stateMachine willEnterForegroundNotification:paramNotification];
}

- (void)didBecomeActiveNotification:(NSNotification*)paramNotification
{
    [self.stateMachine didBecomeActiveNotification:paramNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.stateMachine viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.stateMachine viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.stateMachine viewWillDisappear];
}

- (BOOL)viewIsVisible
{
    return (self.isViewLoaded && self.view.window);
}

//------------------------------------------------------------------
// TODO: consider moving the following methods to new type
- (BOOL)hasQuestionsInPersistentStorage
{
    return (0<self.fetchedResultsController.fetchedObjects.count);
}

- (NSUInteger)numberOfQuestionsInPersistentStorage
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (NSInteger)mostRecentQuestionId
{
    if (self.hasQuestionsInPersistentStorage) {
        Question* mostRecentQuestion = self.fetchedResultsController.fetchedObjects[0];
        return mostRecentQuestion.question_id.integerValue;
    } else {
        return -1;
    }
}

- (NSInteger)oldestQuestionId
{
    if (self.hasQuestionsInPersistentStorage) {
        Question* mostRecentQuestion = self.fetchedResultsController.fetchedObjects[self.numberOfQuestionsInPersistentStorage-1];
        return mostRecentQuestion.question_id.integerValue;
    } else {
        return -1;
    }
}
//------------------------------------------------------------------

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
    
    [self.stateMachine scrollViewDidScroll:scrollView];
}

- (void)setupRefreshControl
{
    if (!self.refreshControl) {
        UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
        NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!"];
        refreshControl.attributedTitle = title;
        
        [refreshControl addTarget:self
                           action:@selector(refresh:)
                 forControlEvents:UIControlEventValueChanged];
        
        self.refreshControl = refreshControl;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    } else {
        NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!"];
        self.refreshControl.attributedTitle = title;
    }
}

#pragma mark - Refresh Controll delegate
- (void)refresh:(UIRefreshControl*)refreshControl
{
//    NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
//    refreshControl.attributedTitle = title;
//    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.refreshControl endRefreshing];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.refreshControl.hidden = YES;
//        });
//        NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!"];
//        refreshControl.attributedTitle = title;
//    });
    
    NSLog(@"refresh:");
    
    [self.stateMachine refresh:refreshControl];
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
    [self.questionsDataSource fetchNewAndUpdatedGivenMostRecentQuestionId:-1 andOldestQuestionId:-1];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    EPQuestionTableViewCell* updatedCell;
    NSIndexPath* adjustedIndexPath;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
            if (!self.refreshControl) {
                // we are in one of the refreshing state when the table structure has been altered
                // to acomodate refreshing indicator in the first row
                // we need to adjust the index path returned by fetched results controller
                adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            } else {
                adjustedIndexPath = indexPath;
            }
            updatedCell = (EPQuestionTableViewCell*)[self.tableView cellForRowAtIndexPath:adjustedIndexPath];
            [updatedCell formatCellForQuestion:question];
            break;
        default:
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.stateMachine controllerDidChangeContent];
}

@end
