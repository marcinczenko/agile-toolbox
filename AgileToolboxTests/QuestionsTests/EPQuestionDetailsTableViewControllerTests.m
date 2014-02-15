//
//  EPQuestionDetailsTableViewControllerTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 15/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionDetailsTableViewController.h"
#import "EPPersistentStoreHelper.h"

#import "Question.h"

#import "EPAppDelegate.h"

static NSString* const referenceDate = @"11 01 2014 12:00 PM";
static NSString* const persistentStoreTestFileName = @"EPQuestionDetailsTableViewControllerTests.data";

@interface EPQuestionDetailsTableViewControllerTests : XCTestCase

@property (nonatomic,strong) EPQuestionDetailsTableViewController* questionDetailsTableViewController;

@end

@implementation EPQuestionDetailsTableViewControllerTests

- (NSDate*)getExampleNSDateObject
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd MM yyyy HH:mm a"];
    return [df dateFromString:referenceDate];
}

- (Question*)setupExampleQuestion
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Question *aQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    aQuestion.header = @"Question Header";
    aQuestion.content = @"QUestion Content";
    aQuestion.answer = @"Answer";
    aQuestion.updated = [self getExampleNSDateObject];
    
    return aQuestion;
}

- (void)setUp
{
    [super setUp];

    self.questionDetailsTableViewController = [[EPQuestionDetailsTableViewController alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatInjectedQuestionObjectIsCopiedAppropriately
{
    Question* aQuestion = [self setupExampleQuestion];
    self.questionDetailsTableViewController.question = aQuestion;
    
    XCTAssertEqualObjects(aQuestion.header, self.questionDetailsTableViewController.questionHeader);
    XCTAssertEqualObjects(aQuestion.content, self.questionDetailsTableViewController.questionContent);
    XCTAssertEqualObjects(aQuestion.answer, self.questionDetailsTableViewController.questionAnswer);
    XCTAssertEqualObjects(aQuestion.updated, self.questionDetailsTableViewController.questionUpdated);
}

- (void)testStoringAndRestoringObjectStateFromMemory
{
    Question* aQuestion = [self setupExampleQuestion];
    self.questionDetailsTableViewController.question = aQuestion;
    
    [EPPersistentStoreHelper archiveObject:self.questionDetailsTableViewController toFile:persistentStoreTestFileName];
    
    EPQuestionDetailsTableViewController* restored = [EPPersistentStoreHelper unarchiveObjectFromFile:persistentStoreTestFileName];
    
    XCTAssertEqualObjects(aQuestion.header, restored.questionHeader);
    XCTAssertEqualObjects(aQuestion.content, restored.questionContent);
    XCTAssertEqualObjects(aQuestion.answer, restored.questionAnswer);
    XCTAssertEqualObjects(aQuestion.updated, restored.questionUpdated);
}


@end
