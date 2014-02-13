//
//  EPQuestionTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 12/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPQuestionTableViewCell.h"
#import "EPAppDelegate.h"

@interface EPQuestionTableViewCellTests : XCTestCase

@property (nonatomic,strong) id imageNewOrUpdatedMock;
@property (nonatomic,strong) id imageAnsweredMock;
@property (nonatomic,strong) id indicatorSlotLeftMock;
@property (nonatomic,strong) id indicatorSlotRightMock;

@property (nonatomic,strong) EPQuestionTableViewCell* questionCell;

@end

@implementation EPQuestionTableViewCellTests

- (NSNumber*)generateExampleDate
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"dd MM yyyy HH:mm:ss.SSSSSS ZZZZ"];
    NSDate *date = [NSDate date];
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

- (void)setUp
{
    [super setUp];
    
    self.imageNewOrUpdatedMock = [OCMockObject mockForClass:[UIImage class]];
    self.imageAnsweredMock = [OCMockObject mockForClass:[UIImage class]];
    self.indicatorSlotLeftMock = [OCMockObject mockForClass:[UIImageView class]];
    self.indicatorSlotRightMock = [OCMockObject mockForClass:[UIImageView class]];
    
    [self.indicatorSlotLeftMock setExpectationOrderMatters:YES];
    [self.indicatorSlotRightMock setExpectationOrderMatters:YES];
    
    self.questionCell = [[EPQuestionTableViewCell alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (Question*)createExampleQuestionThatIsNew:(BOOL)isNew andAnswered:(BOOL)isAnswered
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSDate* dateNow = [NSDate date];
    
    question.header = @"Question Header";
    question.content = @"Question Content";
    question.answer = isAnswered ? @"Question Answer" : nil;
    question.created = dateNow;
    question.updated = dateNow;
    question.updatedOrNew = isNew ? @YES : @NO;
    
    return question;
}

- (Question*)questionWithUpdated:(NSDate*)updated
{
    EPAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:appDelegate.managedObjectContext];
    
    question.updated = updated;
    
    return question;
}

- (void)setupMocksForCellMock:(id)cellMock
{
    [[[cellMock stub] andReturn:self.imageNewOrUpdatedMock] markerNewOrUpdated];
    [[[cellMock stub] andReturn:self.imageAnsweredMock] markerAnswered];
    [[[cellMock stub] andReturn:self.indicatorSlotLeftMock] indicatorSlotLeft];
    [[[cellMock stub] andReturn:self.indicatorSlotRightMock] indicatorSlotRight];
}

- (void)testThatImagesAreConfiguredCorrectlyWhenMarkingQuestionNewAndNotAnswered
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [self setupMocksForCellMock:questionCellPartialMock];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageNewOrUpdatedMock];
    [[self.indicatorSlotRightMock expect] setImage:nil];
    
    self.questionCell.markedAsNew = YES;
    
    [self.indicatorSlotLeftMock verify];
    [self.indicatorSlotRightMock verify];
}

- (void)testThatImagesAreConfiguredCorrectlyWhenMarkingQuestionAnsweredButNotNew
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [self setupMocksForCellMock:questionCellPartialMock];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageAnsweredMock];
    [[self.indicatorSlotRightMock expect] setImage:nil];
    
    self.questionCell.markedAsAnswered = YES;
    
    [self.indicatorSlotLeftMock verify];
    [self.indicatorSlotRightMock verify];
}

- (void)testThatImagesAreConfiguredCorrectlyWhenFirstMarkingQuestionNewAndThenAnswered
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [self setupMocksForCellMock:questionCellPartialMock];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageNewOrUpdatedMock];
    [[self.indicatorSlotRightMock expect] setImage:nil];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageNewOrUpdatedMock];
    [[self.indicatorSlotRightMock expect] setImage:self.imageAnsweredMock];
    
    self.questionCell.markedAsNew = YES;
    self.questionCell.markedAsAnswered = YES;
    
    [self.indicatorSlotLeftMock verify];
    [self.indicatorSlotRightMock verify];
}

- (void)testThatImagesAreConfiguredCorrectlyWhenFirstMarkingQuestionAnsweredAndThenNew
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [self setupMocksForCellMock:questionCellPartialMock];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageAnsweredMock];
    [[self.indicatorSlotRightMock expect] setImage:nil];
    
    [[self.indicatorSlotLeftMock expect] setImage:self.imageNewOrUpdatedMock];
    [[self.indicatorSlotRightMock expect] setImage:self.imageAnsweredMock];
    
    self.questionCell.markedAsAnswered = YES;
    self.questionCell.markedAsNew = YES;
    
    [self.indicatorSlotLeftMock verify];
    [self.indicatorSlotRightMock verify];
}

- (void)testThatStatusIndicatorsAreConfiguredCorrectlyWhenQuestionIsNewButNotAnswered
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [[questionCellPartialMock expect] setMarkedAsNew:YES];
    [[questionCellPartialMock expect] setMarkedAsAnswered:NO];
    
    Question* question = [self createExampleQuestionThatIsNew:YES andAnswered:NO];
    
    [self.questionCell formatCellForQuestion:question];
    
    [questionCellPartialMock verify];
}

- (void)testThatStatusIndicatorsAreConfiguredCorrectlyWhenQuestionIsAnsweredButNotNew
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [[questionCellPartialMock expect] setMarkedAsNew:NO];
    [[questionCellPartialMock expect] setMarkedAsAnswered:YES];
    
    Question* question = [self createExampleQuestionThatIsNew:NO andAnswered:YES];
    
    [self.questionCell formatCellForQuestion:question];
    
    [questionCellPartialMock verify];
}

- (void)testThatStatusIndicatorsAreConfiguredCorrectlyWhenQuestionIsNewAndAnswered
{
    id questionCellPartialMock = [OCMockObject partialMockForObject:self.questionCell];
    [[questionCellPartialMock expect] setMarkedAsNew:YES];
    [[questionCellPartialMock expect] setMarkedAsAnswered:YES];
    
    Question* question = [self createExampleQuestionThatIsNew:YES andAnswered:YES];
    
    [self.questionCell formatCellForQuestion:question];
    
    [questionCellPartialMock verify];
}


@end
