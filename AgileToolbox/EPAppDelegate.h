//
//  EPAppDelegate.h
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EPDependencyBox.h"


#import "EPQuestionsDataSource.h"
#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionPostman.h"

@interface EPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// The following three properties are for CoreData
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic) EPDependencyBox* questionsTableViewControllerDependencyBox;

// The following two methods are for CoreData
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// This method is only used for the purpose of testing - should be removed from production code
-(void)clearPersistentStore;

@end
