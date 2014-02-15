//
//  EPQuestionUpdatedDateTimeViewTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "EPOverlayNotifierView.h"

@interface EPOverlayNotifierViewTests : XCTestCase

@property (nonatomic,strong) EPOverlayNotifierView* overlayView;
@property (nonatomic,strong) id viewMock;
@property (nonatomic,assign) NSTimeInterval timeInterval;

@end

@implementation EPOverlayNotifierViewTests

- (void)setUp
{
    [super setUp];
    
    self.viewMock = [OCMockObject niceMockForClass:[UIView class]];
    
    self.overlayView = [[EPOverlayNotifierView alloc] initWithTableViewFrame:CGRectMake(0, 0, 0, 0)];
    
    self.timeInterval = 1.0;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testOverlayViewHasTagSet
{
    XCTAssertEqual([EPOverlayNotifierView tagValue], self.overlayView.tag);
}

- (void)testOverlayViewHasTextAlignementCenterAsDefault
{
    XCTAssertEqual(NSTextAlignmentCenter, self.overlayView.textAlignment);
}

- (void)testAddingOverlayViewToAnotherView
{
    [[self.viewMock expect] addSubview:self.overlayView];
    
    [self.overlayView addToView:self.viewMock for:self.timeInterval];
    
    [self.viewMock verify];
}

@end
