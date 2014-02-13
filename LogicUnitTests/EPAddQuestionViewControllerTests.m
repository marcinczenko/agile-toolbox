//
//  EPAddQuestionViewControllerTests.m
//  AgileToolbox
//
//  Created by AtrBea on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "EPAddQuestionViewController.h"
#import "EPAddQuestionDelegateProtocol.h"

@interface EPAddQuestionViewControllerTests : XCTestCase

@property (nonatomic,readonly) id doesNotMatter;

@end


@implementation EPAddQuestionViewControllerTests

- (id)doesNotMatter
{
    return nil;
}

- (void)testThatAddedQuestionTextFieldHasAccessabilityLabelSet
{
    EPAddQuestionViewController* vc = [[EPAddQuestionViewController alloc] init];
    
    id addQuestionVC = [OCMockObject partialMockForObject:vc];
    id textFieldMock = [OCMockObject mockForClass:[UITextField class]];
    [[textFieldMock expect] setAccessibilityLabel:@"NewQuestionTextField"];
    [[[addQuestionVC stub] andReturn:textFieldMock] addedQuestionText];
    
    [vc viewDidLoad];
    
    [addQuestionVC verify];
    [textFieldMock verify];
}

- (void)testTheDoneActionDismissesTheModalControllerAndCallsTheDelegate
{
    EPAddQuestionViewController* vc = [[EPAddQuestionViewController alloc] init];
        
    id addQuestionVCPartialMock = [OCMockObject partialMockForObject:vc];
    [[addQuestionVCPartialMock expect] dismissViewControllerAnimated:YES completion:nil];
    
    id textFieldMock = [OCMockObject mockForClass:[UITextField class]];
    [[[textFieldMock stub] andReturn:@"New Question"] text];
    
    [[[addQuestionVCPartialMock stub] andReturn:textFieldMock] addedQuestionText]; 
    
    id delegateMock = [OCMockObject mockForProtocol:@protocol(EPAddQuestionDelegateProtocol)];
    [[delegateMock expect] questionAdded:@"New Question"];
    
    vc.delegate = delegateMock;
    
    [vc done:self.doesNotMatter];
    
    [delegateMock verify];
    [addQuestionVCPartialMock verify];
}

- (void)testTheCancelActionOnlyDismissesTheModal
{
    EPAddQuestionViewController* vc = [[EPAddQuestionViewController alloc] init];
    
    id addQuestionVCPartialMock = [OCMockObject partialMockForObject:vc];
    [[addQuestionVCPartialMock expect] dismissViewControllerAnimated:YES completion:nil];
    
    [vc cancel:self.doesNotMatter];
    
    [addQuestionVCPartialMock verify];
}

@end
