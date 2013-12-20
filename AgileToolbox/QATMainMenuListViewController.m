//
//  QATMainMenuListViewController.m
//  AgileToolbox
//
//  Created by AtrBea on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATAppDelegate.h"
#import "QATMainMenuListViewController.h"
#import "QATMenuListSmartTableViewCell.h"

#import "QATQuestionsTableViewController.h"
#import "QATConnection.h"
#import "QATQuestionsDataSource.h"

#import "QATTopicsListViewController.h"


@interface QATMainMenuListViewController ()

@end

@implementation QATMainMenuListViewController

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
    
    self.view.accessibilityLabel = @"MenuList";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImageView *quantumLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QuantumNavigationBarLogo"]];
    
    self.navigationItem.titleView = quantumLogo;
    self.title = @"Quantum Agile Toolbox";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Questions"]) {
        
        QATQuestionsTableViewController* destinationVC =  (QATQuestionsTableViewController*)segue.destinationViewController;
        QATAppDelegate* appDelegate = (QATAppDelegate*)[[UIApplication sharedApplication] delegate];
        destinationVC.questionsDataSource = appDelegate.questionsDataSource;
        destinationVC.postman = appDelegate.postman;
    }
//    else
//    {
//        QATTopicsListViewController* destinationVC = (QATTopicsListViewController*)segue.destinationViewController;
//    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QATMenuListSmartTableViewCell* cell = [QATMenuListSmartTableViewCell cellForTableView:tableView];
    
    
    if(0==indexPath.row)
    {
        cell.textLabel.text = @"Q&A";
        cell.accessibilityLabel = cell.textLabel.text;
    }
    else
    {
        cell.textLabel.text = @"Topics";
        cell.accessibilityLabel = cell.textLabel.text;
    }
    
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
    if (0==indexPath.row) {
        [self performSegueWithIdentifier: @"Questions" sender: self];
    }
    else
    {
        [self performSegueWithIdentifier: @"Topics" sender: self];
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
