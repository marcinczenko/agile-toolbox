//
//  EPQuestionsTableViewControllerDependencyBootstrapper.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import "EPQuestionsTableViewControllerDependencyBootstrapper.h"

#import "EPQuestionsDataSource.h"
#import "EPConnection.h"

#import "EPQuestionsTableViewControllerStateMachine.h"

#import "EPQuestionPostman.h"
#import "EPJSONPostURLRequest.h"

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"


#import "EPAppDelegate.h"

@interface EPQuestionsTableViewControllerDependencyBootstrapper ()

@property (nonatomic,weak) EPAppDelegate* appDelegate;

@end

@implementation EPQuestionsTableViewControllerDependencyBootstrapper

static const NSString* hostURL = @"http://everydayproductive-test.com:9001";
//static const NSString* hostURL = @"http://192.168.1.33:9001";

- (instancetype)initWithAppDelegate:(EPAppDelegate*)appDelegate
{
    if ((self=[super init])) {
        _appDelegate = appDelegate;
    }
    
    return self;
}

- (EPQuestionsDataSource*)bootstrapDataSource
{
    EPConnection* connection = [EPConnection createWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/items_json",hostURL]]];
    EPQuestionsDataSource* dataSource = [[EPQuestionsDataSource alloc] initWithConnection:connection
                                                              andWithManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [dataSource restoreFromPersistentStorage];
    
    return dataSource;
}

- (NSFetchedResultsController*)bootstrapFetchedResultsController
{
    NSFetchRequest *questionsFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    
    questionsFetchRequest.sortDescriptors = @[createdSort];
    
    NSFetchedResultsController* questionsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:questionsFetchRequest
                                                                                                        managedObjectContext:self.appDelegate.managedObjectContext
                                                                                                          sectionNameKeyPath:nil
                                                                                                                   cacheName:nil];
    NSError *fetchError = nil;
    [questionsFetchedResultsController performFetch:&fetchError];
    
    return questionsFetchedResultsController;
}

- (EPQuestionsTableViewControllerStateMachine*)bootstrapStateMachine
{
    return [[EPQuestionsTableViewControllerStateMachine alloc] init];
}

- (EPQuestionPostman*)bootstrapPostman
{
    EPJSONPostURLRequest* postRequest = [[EPJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/new_json_item",hostURL]]];
    EPConnection* postConnection = [[EPConnection alloc] initWithURLRequest:postRequest];
    return [[EPQuestionPostman alloc] initWithConnection:postConnection];
}

- (EPQuestionsTableViewControllerStatePreservationAssistant*)bootstrapPreservationAssistant
{
    return [EPQuestionsTableViewControllerStatePreservationAssistant restoreFromPersistentStorage];
}

- (EPDependencyBox*)bootstrap
{
    EPDependencyBox* dependencyBox = [[EPDependencyBox alloc] init];
    
    dependencyBox[@"DataSource"] = [self bootstrapDataSource];
    dependencyBox[@"FetchedResultsController"] = [self bootstrapFetchedResultsController];
    dependencyBox[@"StateMachine"] = [self bootstrapStateMachine];
    dependencyBox[@"Postman"] = [self bootstrapPostman];
    dependencyBox[@"StatePreservationAssistant"] = [self bootstrapPreservationAssistant];
    
    return dependencyBox;
}

@end
