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

//static const NSString* hostURL = @"http://everydayproductive-test.com:9001";

#define OBJCSTR(str) @#str
#define OBJCSTR_FROM_URL(url) OBJCSTR(url)

#ifdef QUESTIONS_URL
static NSString* const hostURL = @"http://"  OBJCSTR_FROM_URL(QUESTIONS_URL);
#else
static NSString* const hostURL = @"https://ep-qat-dev-1.appspot.com";
#endif

static NSString* const QUESTIONS_JSON_URL = @"/questions_json";
static NSString* const ADD_QUESTION_JSON_URL = @"/add_question_json";

- (instancetype)initWithAppDelegate:(EPAppDelegate*)appDelegate
{
    if ((self=[super init])) {
        _appDelegate = appDelegate;
    }
    
    return self;
}

- (EPQuestionsDataSource*)bootstrapDataSource
{
    NSLog(@"hostURL:%@",hostURL);
    EPConnection* connection = [EPConnection createWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostURL,QUESTIONS_JSON_URL]]];
    EPQuestionsDataSource* dataSource = [[EPQuestionsDataSource alloc] initWithConnection:connection
                                                              andWithManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [dataSource restoreFromPersistentStorage];
    
    return dataSource;
}

- (NSFetchedResultsController*)bootstrapFetchedResultsController
{
    NSFetchRequest *questionsFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
//    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSSortDescriptor *updatedSort = [[NSSortDescriptor alloc] initWithKey:@"sortUpdated" ascending:NO];
    
//    questionsFetchRequest.sortDescriptors = @[createdSort];
    questionsFetchRequest.sortDescriptors = @[updatedSort];
    
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
    EPJSONPostURLRequest* postRequest = [[EPJSONPostURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostURL,ADD_QUESTION_JSON_URL]]];
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
