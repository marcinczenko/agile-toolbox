//
//  EPQuestionsTableViewControllerStateMachine.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerStateMachine.h"
#import "EPQuestionsTableViewControllerInitialState.h"
#import "EPQuestionsTableViewControllerEmptyLoadingState.h"
#import "EPQuestionsTableViewControllerEmptyNoQuestionsState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreState.h"
#import "EPQuestionsTableViewControllerQuestionsNoMoreToFetchState.h"
#import "EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState.h"
#import "EPQuestionsTableViewControllerQuestionsLoadingState.h"

@interface EPQuestionsTableViewControllerStateMachine ()

@property (nonatomic,strong) EPQuestionsTableViewControllerState* currentState;

@property (nonatomic,weak) EPQuestionsTableViewController* viewController;
@property (nonatomic,weak) EPQuestionsTableViewExpert* tableViewExpert;
@property (nonatomic,strong) NSMutableDictionary* stateObjects;

@end

@implementation EPQuestionsTableViewControllerStateMachine

- (id)init
{
    if ((self = [super init])) {
        _stateObjects = [NSMutableDictionary new];
        [EPQuestionsTableViewControllerStateMachine populateStatesDictionary:_stateObjects
                                                            withStateMachine:self];
        _currentState = _stateObjects[NSStringFromClass([EPQuestionsTableViewControllerInitialState class])];
    }
    return self;
}

- (void)assignViewController:(EPQuestionsTableViewController*)viewController andTableViewExpert:(EPQuestionsTableViewExpert*)tableViewExpert
{
    self.viewController = viewController;
    self.tableViewExpert = tableViewExpert;
    [self.stateObjects enumerateKeysAndObjectsUsingBlock:^(NSString* stateName, EPQuestionsTableViewControllerState* stateObj, BOOL *stop) {
        stateObj.viewController = viewController;
        stateObj.tableViewExpert = tableViewExpert;
    }];
}

+ (void)populateStatesDictionary:(NSMutableDictionary*)dictionary
                withStateMachine:(EPQuestionsTableViewControllerStateMachine*)stateMachine
{
    NSArray *stateClasses = @[[EPQuestionsTableViewControllerInitialState class],
                              [EPQuestionsTableViewControllerEmptyLoadingState class],
                              [EPQuestionsTableViewControllerEmptyNoQuestionsState class],
                              [EPQuestionsTableViewControllerQuestionsWithFetchMoreState class],
                              [EPQuestionsTableViewControllerQuestionsNoMoreToFetchState class],
                              [EPQuestionsTableViewControllerQuestionsWithFetchMoreRespondingToScrollState class],
                              [EPQuestionsTableViewControllerQuestionsLoadingState class]];
    
    for (Class stateClass in stateClasses) {
        dictionary[NSStringFromClass(stateClass)] = [[stateClass alloc] initWithStateMachine:stateMachine];
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
