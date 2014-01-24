//
//  EPAppDelegate.m
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EPAppDelegate.h"
#import "EPConnection.h"
#import "EPJSONPostURLRequest.h"
#import "EPQuestionsTableViewController.h"

@interface EPAppDelegate ()

@property (strong, nonatomic) NSFetchedResultsController *questionsFetchedResultsController;
@property (strong, nonatomic) EPQuestionsDataSource* questionsDataSource;
@property (strong, nonatomic) EPQuestionsTableViewControllerStateMachine* questionsTableViewControllerStateMachine;
@property (strong, nonatomic) EPQuestionPostman* postman;

@property (weak, nonatomic) id<NSFetchedResultsControllerDelegate> questionsFetchedResultsControllerDelegate;

@end

@implementation EPAppDelegate

static const NSString* hostURL = @"http://everydayproductive-test.com:9001";
//static const NSString* hostURL = @"http://192.168.1.33:9001";

// The following three @synthesize statements are for CoreData
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize window = _window;
@synthesize questionsDataSource = _questionsDataSource;
@synthesize postman = _postman;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData;
    
    responseData = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/ready",hostURL]]]
                                         returningResponse:&response
                                                     error:&error];
                                                                        
    if ([responseData length] > 0)
    {
        NSLog(@"Upload response: %@",[NSString stringWithCString:[responseData bytes]
                                                        encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Bad response (%@)", [error description]);
    }
    
    
    EPConnection* connection = [EPConnection createWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/items_json",hostURL]]];
    
    NSFetchRequest *questionsFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *timestampSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];

    questionsFetchRequest.sortDescriptors = @[timestampSort];
    
    self.questionsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:questionsFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *fetchError = nil;
    [self.questionsFetchedResultsController performFetch:&fetchError];
    
    self.questionsTableViewControllerStateMachine = [[EPQuestionsTableViewControllerStateMachine alloc] init];
    
    self.questionsDataSource = [[EPQuestionsDataSource alloc] initWithConnection:connection
                                               andWithManagedObjectContext:self.managedObjectContext];
    
    EPJSONPostURLRequest* postRequest = [[EPJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/new_json_item",hostURL]]];
    EPConnection* postConnection = [[EPConnection alloc] initWithURLRequest:postRequest];
    self.postman = [[EPQuestionPostman alloc] initWithConnection:postConnection];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    if (![NSThread isMainThread]) {
        NSLog(@"WE ARE NOT IN THE MAIN THREAD!!!!!!!!!!!!!");
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    if (![NSThread isMainThread]) {
        NSLog(@"WE ARE NOT IN THE MAIN THREAD!!!!!!!!!!!!!");
    }
    
    self.questionsFetchedResultsControllerDelegate = self.questionsFetchedResultsController.delegate;
    self.questionsFetchedResultsController.delegate = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    
    self.questionsFetchedResultsController.delegate = self.questionsFetchedResultsControllerDelegate;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    
    EPQuestionsTableViewController* vc = (EPQuestionsTableViewController*)self.questionsFetchedResultsController.delegate;
    
    NSError *fetchError = nil;
    [self.questionsFetchedResultsController performFetch:&fetchError];
    
    [vc.tableView reloadData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // TODO
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AgileToolbox" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AgileToolbox.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - This method is only used for the purpose of testing - should be removed from production code

-(void)clearPersistentStore
{
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
}

@end
