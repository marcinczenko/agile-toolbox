//
//  QATAppDelegate.m
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATAppDelegate.h"
#import "QATConnection.h"
#import "QATJSONPostURLRequest.h"

@interface QATAppDelegate ()

@property (strong, nonatomic) QATQuestionsDataSource* questionsDataSource;
@property (strong, nonatomic) QATQuestionPostman* postman;

@end

@implementation QATAppDelegate

@synthesize window = _window;
@synthesize questionsDataSource = _questionsDataSource;
@synthesize postman = _postman;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData;
    
    responseData = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:9001/ready"]]
                                         returningResponse:&response
                                                     error:&error];
                                                                        
    if ([responseData length] > 0)
    {
        NSLog(@"Upload response: %@",[NSString stringWithCString:[responseData bytes]
                                                        encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Bad response (%@)", [error description]);
    }
    
    
    QATConnection* connection = [QATConnection createWithURL:[NSURL URLWithString:@"http://localhost:9001/items_json"]];
    self.questionsDataSource = [[QATQuestionsDataSource alloc] initWithConnection:connection];
    
    QATJSONPostURLRequest* postRequest = [[QATJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:9001/new_json_item"]];
    QATConnection* postConnection = [[QATConnection alloc] initWithURLRequest:postRequest];
    self.postman = [[QATQuestionPostman alloc] initWithConnection:postConnection];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
