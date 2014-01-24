//
//  EPQuestionsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPQuestionsTableViewController.h"
#import "EPAddQuestionViewController.h"

#import "EPQuestionsDataSourceProtocol.h"
#import "EPPostmanProtocol.h"

#import "EPQuestionsTableViewControllerState.h"


@interface EPQuestionsTableViewControllerTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewController* vc;
@property (nonatomic,strong) id questionsTableViewControllePartialMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id questionsDataSourceMock;

@property (nonatomic,strong) id stateMachineMock;
@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;

@property (nonatomic,strong) id postmanMock;
@property (nonatomic,strong) id navigationControllerMock;
@property (nonatomic,strong) id addQuestionController;
@property (nonatomic,strong) id segueMock;

@property (nonatomic,readonly) id doesNotMatter;

@end


@implementation EPQuestionsTableViewControllerTests

BOOL valueYES = YES;
BOOL valueNO = NO;

- (id)doesNotMatter
{
    return nil;
}

- (NSInteger)magicNumber:(NSInteger)number
{
    return number;
}

- (void)disableViewPropertyForTheVC
{
    // Everywhere we access the view property we will return nil, so that the view
    // will not be instatiated in the logic unit tests. If we let it happen
    // the viewDidLoad may be invoked more than once, and it costs unnecessary time
    // for something we do not want to test here.
    [[[self.questionsTableViewControllePartialMock stub] andReturn:nil] view];
}

-(void)mockTableView
{
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)mockTableViewExpert
{
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
}

- (void)setUp
{
    self.vc = [[EPQuestionsTableViewController alloc] init];
    self.questionsTableViewControllePartialMock = [OCMockObject partialMockForObject:self.vc];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    self.questionsDataSourceMock = [OCMockObject niceMockForProtocol:@protocol(EPQuestionsDataSourceProtocol)];
    
    self.stateMachineMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewControllerStateMachine class]];
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
    
    self.postmanMock = [OCMockObject niceMockForProtocol:@protocol(EPPostmanProtocol)];
    self.navigationControllerMock = [OCMockObject niceMockForClass:[UINavigationController class]];
    self.addQuestionController = [OCMockObject niceMockForClass:[EPAddQuestionViewController class]];
    self.segueMock = [OCMockObject niceMockForClass:[UIStoryboardSegue class]];
}

- (void)testQATQuestionTableViewControllerHasPropertyForDataSource
{
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    XCTAssertEqualObjects(self.vc.questionsDataSource, self.questionsDataSourceMock);
}

- (void)testQATQuestionTableViewControllerHasPropertyForFetchedResultsController
{
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    XCTAssertEqualObjects(self.vc.fetchedResultsController, self.fetchedResultsControllerMock);
}

- (void)testQATQuestionTableViewControllerHasPropertyForStateMachine
{
    self.vc.stateMachine = self.stateMachineMock;
    XCTAssertEqualObjects(self.vc.stateMachine, self.stateMachineMock);
}

- (void)testThatViewDidLoadInitializesTableViewExpert
{
    [self disableViewPropertyForTheVC];
    
    [self.vc viewDidLoad];
    
    XCTAssertNotNil(self.vc.tableViewExpert);
}

- (void)testThatTableViewExpertIsAssociatedWithTheRightTableViewObject
{
    [self disableViewPropertyForTheVC];
    [self mockTableView];
    [[self.tableViewMock expect] setDelegate:self.vc];
    
    [self.vc viewDidLoad];
    
    XCTAssertNotNil(self.vc.tableViewExpert.tableView);
    XCTAssertEqualObjects(self.vc.tableView, self.vc.tableViewExpert.tableView);
}

- (void)testThatViewDidLoadAssignsViewControllerAndTableViewExpertToTheStateMachine
{
    [self disableViewPropertyForTheVC];
    
    [[[self.questionsTableViewControllePartialMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
    
    [[self.stateMachineMock expect] assignViewController:self.vc andTableViewExpert:self.tableViewExpertMock];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc viewDidLoad];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatViewDidLoadDelegatesToStateMachine
{
    [self disableViewPropertyForTheVC];

    [[self.stateMachineMock expect] viewDidLoad];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc viewDidLoad];
    
    [self.stateMachineMock verify];
}

- (void)testQATQuestionTableViewControllerHasPropertyForPostmanService
{
    id postmanMock = [OCMockObject mockForProtocol:@protocol(EPPostmanProtocol)];
    
    self.vc.postman = postmanMock;
}

- (void)testThatViewRegistersItselfAsTheDelegateOfThePostman
{
    [self disableViewPropertyForTheVC];
    
    [[self.postmanMock expect] setDelegate:self.vc];
    
    self.vc.postman = self.postmanMock;
    
    [self.vc viewDidLoad];
    
    [self.postmanMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfTheDataSource
{
    [self disableViewPropertyForTheVC];
    
    [[self.questionsDataSourceMock expect] setDelegate:self.vc];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    [self.vc viewDidLoad];
    
    [self.questionsDataSourceMock verify];
}

- (void)testThatViewRegistersItselfAsTheDelegateOfTheFetchedResultsController
{
    [self disableViewPropertyForTheVC];
    
    [[self.fetchedResultsControllerMock expect] setDelegate:self.vc];
    
    self.vc.fetchedResultsController = self.fetchedResultsControllerMock;
    
    [self.vc viewDidLoad];
    
    [self.fetchedResultsControllerMock verify];
}

#pragma StateMachine delegate
- (void)testThatScrollViewDidScrollDelegatesToTheStateMachine
{
    id scrollViewMock = [OCMockObject mockForClass:[UIScrollView class]];
    [[self.stateMachineMock expect] scrollViewDidScroll:scrollViewMock];
    
    [self mockTableViewExpert];
    [[[self.tableViewExpertMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] scrollPositionTriggersFetchingOfTheNextQuestionSetForScrollView:scrollViewMock];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc scrollViewWillBeginDragging:self.doesNotMatter];
    [self.vc scrollViewDidScroll:scrollViewMock];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatNumberOfSectionsInTableViewDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] numberOfSections];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc numberOfSectionsInTableView:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatNumberOfRowsInSectionDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] numberOfRowsInSection:0];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc tableView:self.doesNotMatter numberOfRowsInSection:0];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatCellForRowAtIndexPathDelegatesToTheStateMachine
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[self.stateMachineMock expect] cellForRowAtIndexPath:indexPath];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc tableView:self.doesNotMatter cellForRowAtIndexPath:indexPath];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatFetchReturnedNoDataDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] fetchReturnedNoData];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc fetchReturnedNoData];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatFetchReturnedNoDataInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] fetchReturnedNoDataInBackground];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc fetchReturnedNoDataInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatControllerDidChangeContentDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] controllerDidChangeContent];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc controllerDidChangeContent:self.doesNotMatter];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatDataChangedInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] dataChangedInBackground];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc dataChangedInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatConnectionFailureInBackgroundDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] connectionFailureInBackground];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc connectionFailureInBackground];
    
    [self.stateMachineMock verify];
}

#pragma StateMachine delegate
- (void)testThatConnectionFailureDelegatesToTheStateMachine
{
    [[self.stateMachineMock expect] connectionFailure];
    
    self.vc.stateMachine = self.stateMachineMock;
    [self.vc connectionFailure];
    
    [self.stateMachineMock verify];
}

- (void)testThatViewSetsTheReferenceToDataSourceToNilWhenMemoryWarningReceived
{
    [self disableViewPropertyForTheVC];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.questionsDataSource);
}

- (void)testThatViewSetsTheReferenceToPostmanToNilWhenMemoryWarningReceived
{
    [self disableViewPropertyForTheVC];
    
    self.vc.postman = self.postmanMock;
    
    [self.vc didReceiveMemoryWarning];
    
    XCTAssertNil(self.vc.postman);
}

- (void)testThatCurrentViewControllerIsSetToBeDelegateOfTheDestinationControllerOnPerformingAddQuestionSegue
{
    [[[self.navigationControllerMock stub] andReturn:self.addQuestionController] topViewController];
    [[self.addQuestionController expect] setDelegate:self.vc];

    [[[self.segueMock stub] andReturn:@"AddQuestion"] identifier];
    [[[self.segueMock stub] andReturn:self.navigationControllerMock] destinationViewController];
    
    [self.vc prepareForSegue:self.segueMock sender:self.doesNotMatter];
    
    [self.addQuestionController verify];
    [self.segueMock verify];
}

- (void)testThatAppropriatePostmanMethodIsCalledWhenNewQuestionIsAdded
{
    NSString * addedQuestion = @"New Question";
    
    [[self.postmanMock expect] post:addedQuestion];

    self.vc.postman = self.postmanMock;

    [self.vc questionAdded:addedQuestion];

    [self.postmanMock verify];
}

- (void)testThatDataSourceDownloadIsForcedWhenPostmanConfirmesThatANewQuestionHasBeenAddedSuccessfully
{
    [[self.questionsDataSourceMock expect] fetchNew];
    
    self.vc.questionsDataSource = self.questionsDataSourceMock;
    
    [self.vc postDelivered];
    
    [self.questionsDataSourceMock verify];
}

@end
