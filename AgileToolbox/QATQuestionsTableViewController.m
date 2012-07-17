//
//  QATQuestionsTableViewController.m
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import "QATQuestionsTableViewController.h"
#import "QATQuestionsSmartTableViewCell.h"
#import "QATAddQuestionViewController.h"

@interface QATQuestionsTableViewController ()

@end

@implementation QATQuestionsTableViewController
@synthesize questionsDataSource = _dataSource;
@synthesize postman = _postman;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityLabel = @"Questions";
    
    [self.questionsDataSource setDelegate:self];
    
    [self.questionsDataSource downloadData];
    
    [self.postman setDelegate:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillUnload
{
    self.questionsDataSource = nil;
    self.postman = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddQuestion"]) {
        
        UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
        
        QATAddQuestionViewController* destinationVC =  (QATAddQuestionViewController*)navigationController.topViewController;
        destinationVC.delegate = self;
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionsDataSource.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QATQuestionsSmartTableViewCell* cell = [QATQuestionsSmartTableViewCell cellForTableView:tableView];
    
    cell.textLabel.text = [self.questionsDataSource questionAtIndex:indexPath.row];
    
    return cell;
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

#pragma mark - QATQuestionsDataSourceDelegate
- (void)dataSoruceLoaded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - QATAddQuestionDelegateProtocol
- (void)questionAdded:(NSString *)question
{
    [self.postman post:question];
}

#pragma mark - QATPostmanDelegateProtocol
- (void)postDelivered
{
    [self.questionsDataSource downloadData];
}

// TODO: not yet supported
- (void)postDeliveryFailed
{
    
}


@end
