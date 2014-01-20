//
//  EPQuestionsTableViewControllerStateMachine.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"

@interface EPQuestionsTableViewControllerStateMachine ()

@property (nonatomic,strong) EPQuestionsTableViewControllerState *currentState;

@property (nonatomic,weak) EPQuestionsTableViewController *viewController;
@property (nonatomic,weak) EPQuestionsTableViewExpert *tableViewExpert;
@property (nonatomic,strong) NSMutableDictionary *stateObjects;

@end

@implementation EPQuestionsTableViewControllerStateMachine

- (id)initWithViewController:(EPQuestionsTableViewController*)viewController andTableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert;
{
    if ((self = [super init])) {
        _viewController = viewController;
        _tableViewExpert = tableViewExpert;
        _stateObjects = [NSMutableDictionary new];
        [EPQuestionsTableViewControllerStateMachine populateStatesDictionary:_stateObjects
                                                          withViewController:_viewController
                                                             tableViewExpert:_tableViewExpert
                                                                AndStateMachine:self];
    }
    return self;
}

+ (void)populateStatesDictionary:(NSMutableDictionary*)dictionary
              withViewController:(EPQuestionsTableViewController*)viewController
                 tableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
                  AndStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    NSArray *stateClasses = @[[EPQuestionsTableViewControllerEmptyLoadingState class],
                              [EPQuestionsTableViewControllerEmptyNoQuestionsState class],
                              [EPQuestionsTableViewControllerQuestionsWithFetchMoreState class],
                              [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class],
                              [EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState class],
                              [EPQuestionsTableViewControllerQuestionsLoadingState class]];
    
    for (Class stateClass in stateClasses) {
        dictionary[NSStringFromClass(stateClass)] = [[stateClass alloc] initWithViewController:viewController
                                                                               tableViewExpert:tableViewExpert
                                                                               andStateMachine:stateMachine];
    }
}

- (void)start
{
    if (0 == self.viewController.fetchedResultsController.fetchedObjects.count) {
        if ([self.viewController.questionsDataSource hasMoreQuestionsToFetch]) {
            [self changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyLoadingState class]];
        }
        else {
            [self changeCurrentStateTo:[EPQuestionsTableViewControllerEmptyNoQuestionsState class]];
        }
    } else {
        if ([self.viewController.questionsDataSource hasMoreQuestionsToFetch]) {
            [self changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsWithFetchMoreState class]];
        }
        else {
            [self changeCurrentStateTo:[EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class]];
        }
    }
}

- (void)changeCurrentStateTo:(Class)stateClass
{
    self.currentState = self.stateObjects[NSStringFromClass(stateClass)];
}

- (void)setStateObject:(id)object forStateName:(NSString*)name
{
    [self.stateObjects setObject:object forKey:name];
}


- (void)viewDidLoad
{
    [self.currentState viewDidLoad];
}

- (void)controllerDidChangeContent
{
    [self.currentState controllerDidChangeContent];
}

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.currentState cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.currentState scrollViewDidScroll:scrollView];
}

- (void)fetchReturnedNoData
{
    [self.currentState fetchReturnedNoData];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.currentState numberOfRowsInSection:section];
}

- (NSInteger)numberOfSections
{
    return [self.currentState numberOfSections];
}

@end
