//
//  EPQuestionsTableViewControllerStateKeeper.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 25/01/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"
#import "EPSnapshot.h"

#import "EPQuestionsTableViewController.h"
#import "EPPersistentStoreHelper.h"
#import "EPAppDelegate.h"
#import "Question.h"

@interface EPQuestionsTableViewControllerStatePreservationAssistantTests : XCTestCase

@property (nonatomic,strong) EPQuestionsTableViewControllerStatePreservationAssistant* preservationAssistant;

@property (nonatomic,strong) id questionsTableViewControllerMock;
@property (nonatomic,strong) id fetchedResultsControllerMock;
@property (nonatomic,strong) id tableViewMock;
@property (nonatomic,strong) id tableViewExpertMock;
@property (nonatomic,strong) id uiImageMock;
@property (nonatomic,strong) id snapshotMock;

@property (nonatomic,readonly) id doesNotMatter;

@end

@implementation EPQuestionsTableViewControllerStatePreservationAssistantTests

static const BOOL valueYES = YES;
static const BOOL valueNO = NO;

- (id)doesNotMatter
{
    return nil;
}

- (void)setUp
{
    [super setUp];
    
    self.preservationAssistant = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] init];
    
    self.questionsTableViewControllerMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewController class]];
    self.fetchedResultsControllerMock = [OCMockObject niceMockForClass:[NSFetchedResultsController class]];
    
    self.tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
    self.tableViewExpertMock = [OCMockObject niceMockForClass:[EPQuestionsTableViewExpert class]];
    self.uiImageMock = [OCMockObject niceMockForClass:[UIImage class]];
    self.snapshotMock = [OCMockObject niceMockForClass:[EPSnapshot class]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)mockFetchedResultsController
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.fetchedResultsControllerMock] fetchedResultsController];
}

- (void)simulateFetchedResultsControllerHasNoData
{
   [[[self.fetchedResultsControllerMock stub] andReturn:@[]] fetchedObjects];
}

- (void)mockTableView
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.tableViewMock] tableView];
    [[[self.tableViewExpertMock stub] andReturn:self.tableViewMock] tableView];
}

- (void)mockTableViewExpert
{
    [[[self.questionsTableViewControllerMock stub] andReturn:self.tableViewExpertMock] tableViewExpert];
}

- (id)questionWithId:(NSNumber*)questionId
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    question.question_id = questionId;
    
    return question;
}

- (NSArray*)questionsWithQuestionIdUpToAndIncluding:(NSInteger)maxId
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray* array = [NSMutableArray new];
    
    for (int i=0; i<maxId+1; i++) {
        Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
        
        question.question_id = [NSNumber numberWithInt:i];
        
        [array addObject:question];
    }
    return array;
}

- (void)simulateFirstVisibleIndexPathToBe:(NSIndexPath*)indexPath
{
    [[[[self.tableViewMock expect] ignoringNonObjectArgs] andReturn:indexPath] indexPathForRowAtPoint:CGPointMake(0, 0)];
    
    NSArray* questions = [self questionsWithQuestionIdUpToAndIncluding:indexPath.row];
    
    [[[self.fetchedResultsControllerMock stub] andReturn:questions[indexPath.row]] objectAtIndexPath:indexPath];
    [[[self.fetchedResultsControllerMock stub] andReturn:questions] fetchedObjects];
    
    [[[self.questionsTableViewControllerMock stub] andReturnValue:OCMOCK_VALUE(valueYES)] hasQuestionsInPersistentStorage];    
}

- (void)testThatStoreToPersistentStorageDelegatesToPersistentStoreHelper
{
    id persistentStoreHelperMock = [OCMockObject mockForClass:[EPPersistentStoreHelper class]];
    [[persistentStoreHelperMock expect] archiveObject:self.preservationAssistant
                                                    toFile:[EPQuestionsTableViewControllerStatePreservationAssistant persistentStoreFileName]];
    
    [self.preservationAssistant storeToPersistentStorage];
    
    [persistentStoreHelperMock verify];
}

- (void)testThatEncodeWithCoderSavesTheIdOfTheFirstVisibleRowToPersistentStorage
{
    id NSURLMock = [OCMockObject niceMockForClass:[NSURL class]];
    
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    [[coder expect] encodeObject:NSURLMock forKey:[EPQuestionsTableViewControllerStatePreservationAssistant kIdOfTheFirstVisibleRow]];
    
    id preservationAssistantPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    [[[preservationAssistantPartialMock stub] andReturn:NSURLMock] idOfTheFirstVisibleRow];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [coder verify];
}

- (void)testThatEncodeWithCoderSavesTheSnapshotOfTheUIToPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    [[coder expect] encodeObject:self.snapshotMock forKey:[EPQuestionsTableViewControllerStatePreservationAssistant kSnapshot]];
    
    id preservationAssistantPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    [[[preservationAssistantPartialMock stub] andReturn:self.snapshotMock] snapshot];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [coder verify];
}

- (void)testThatEncodeWithCoderSavesTheBoundsToPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    self.preservationAssistant.bounds = CGRectMake(0, -64, 320, 568);
    
    [[coder expect] encodeCGRect:self.preservationAssistant.bounds forKey:[EPQuestionsTableViewControllerStatePreservationAssistant kBounds]];
    
    [self.preservationAssistant encodeWithCoder:coder];
    
    [coder verify];
}

- (void)testThatInitWithCoderRestoresTheBoundsFromPersistentStorage
{
    id coder = [OCMockObject niceMockForClass:[NSCoder class]];
    
    CGRect expectedBounds = CGRectMake(0, -64, 320, 568);
    
    [[[coder expect] andReturnValue:OCMOCK_VALUE(expectedBounds)] decodeCGRectForKey:[EPQuestionsTableViewControllerStatePreservationAssistant kBounds]];
    
    EPQuestionsTableViewControllerStatePreservationAssistant* assistant = [[EPQuestionsTableViewControllerStatePreservationAssistant alloc] initWithCoder:coder];
    
    XCTAssertEqual(expectedBounds, assistant.bounds);
    
    [coder verify];
}

- (void)testThatRecordCurrentStateForViewControllerCreatesTheSnapshot
{
    id preservationAssistantPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    [[preservationAssistantPartialMock expect] createSnapshotViewForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant recordCurrentStateForViewController:self.questionsTableViewControllerMock];
    
    [preservationAssistantPartialMock verify];
}

- (void)testThatRecordCurrentStateForViewControllerStoresTheFirstVisibleRowURL
{
    id preservationAssistantPartialMock = [OCMockObject partialMockForObject:self.preservationAssistant];
    [[preservationAssistantPartialMock expect] storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    
    [self.preservationAssistant recordCurrentStateForViewController:self.questionsTableViewControllerMock];
    
    [preservationAssistantPartialMock verify];
}

- (void)testStoringAndRestoringIndexPathOfTheFirstVisibleRow
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:10 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.preservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

- (void)testThatIndexPathIsNotRestoredIfItWasNotStoredInTheFirstPlace
{
    [self mockTableView];
    
    [[[self.tableViewMock reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:[OCMArg any] atScrollPosition:0 animated:NO];
    
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.tableViewMock verify];
}

- (void)testThatRestoringIndexPathClearsTheRestorationHistory
{
    NSIndexPath* indexPathFirstVisibleRow = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockFetchedResultsController];
    [self mockTableView];
    [self simulateFirstVisibleIndexPathToBe:indexPathFirstVisibleRow];
    
    [[self.tableViewMock expect] scrollToRowAtIndexPath:indexPathFirstVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [[[self.tableViewMock reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:[OCMArg any] atScrollPosition:0 animated:NO];
    
    [self.preservationAssistant storeQuestionIdOfFirstVisibleQuestionForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    [self.preservationAssistant restoreIndexPathOfFirstVisibleRowForViewController:self.questionsTableViewControllerMock];
    
    [self.tableViewMock verify];
}

@end
