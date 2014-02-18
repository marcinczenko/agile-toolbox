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


#import "EPOverlayNotifierView.h"

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

@property (nonatomic,strong) EPOverlayNotifierView* updatedDateView;

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
    self.tableViewExpert.viewController = self;
    
    [self.stateMachine assignViewController:self andTableViewExpert:self.tableViewExpert];
    
    [self.stateMachine viewDidLoad];
    
    [self configureNotifications];
    
//    self.questionsRefreshControl = [[EPQuestionsRefreshControl alloc] initWithTableViewController:self refreshBlock:^(id refreshControl) {
//        [self.stateMachine refresh:refreshControl];
//    }];
    
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
    
    [self.updatedDateView addToView:self.view for:3.0];
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
    
//    CGRect r = self.view.frame;
//    CGRect r2 = [self.navigationController.view convertRect:CGRectMake(0, 0, 320, 568) toView:self.tableView];
    
//    NSLog(@"r:%@",NSStringFromCGRect(r));
//    NSLog(@"r2:%@",NSStringFromCGRect(r2));
//    NSLog(@"f:%@",NSStringFromCGRect(self.tableView.frame));
//    NSLog(@"b:%@",NSStringFromCGRect(self.tableView.bounds));
//    NSLog(@"co:%@",NSStringFromCGPoint(self.tableView.contentOffset));
//    NSLog(@"l:%@",NSStringFromCGRect(self.tableView.layer.bounds));
//    NSLog(@"s:%@",NSStringFromCGSize(self.tableView.contentSize));
    
//    CGRect r3 = CGRectMake(0, self.tableView.bounds.origin.y+self.tableView.bounds.size.height,
//                           self.tableView.bounds.size.width, 40.0);
//    
//    self.updatedDateView = [[EPOverlayNotifierView alloc] initWithFrame:r3];
//    self.updatedDateView.text = @"Dupa";
    
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
    [self.stateMachine prepareForSegue:segue];
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

- (UIRefreshControl*)autoInitRefreshControl
{
    if (!self.refreshControl) {
        [self setupRefreshControl];
    }
    
    return self.refreshControl;
}

- (void)setRefreshControlText:(NSString*)text
{
    UIFont* font = [UIFont fontWithName:@"Helvetica-Light" size:10];
    
    NSAttributedString* title =  [[NSAttributedString alloc] initWithString:text
                                                                 attributes: @{ NSFontAttributeName: font,
                                                                                NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.autoInitRefreshControl.attributedTitle = title;
}

- (void)endRefreshing
{
    [self.autoInitRefreshControl endRefreshing];
    
    [self setRefreshControlText:@"Pull to Refresh!"];
}

- (void)setupRefreshControl
{
    if (!self.refreshControl) {
        UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
//        UIRefreshControl* refreshControl = self.questionsRefreshControl;
        UIFont* headerFont = [UIFont fontWithName:@"Helvetica-Light" size:10];
        
        NSAttributedString* title =  [[NSAttributedString alloc] initWithString:@"Pull to Refresh!"
                                                                               attributes: @{ NSFontAttributeName: headerFont,
                                                                                              NSForegroundColorAttributeName: [UIColor blackColor]}];
        
        refreshControl.attributedTitle = title;
        
        [refreshControl addTarget:self
                           action:@selector(refresh:)
                 forControlEvents:UIControlEventValueChanged];
        
        self.refreshControl = refreshControl;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    }
}

#pragma mark - Refresh Controll delegate
- (void)refresh:(UIRefreshControl*)refreshControl
{
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

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.stateMachine heightForRowAtIndexPath:indexPath];
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
    [self.stateMachine controllerWillChangeContent];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(Question*)question atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.stateMachine controllerDidChangeQuestion:question atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.stateMachine controllerDidChangeContent];
}

@end
