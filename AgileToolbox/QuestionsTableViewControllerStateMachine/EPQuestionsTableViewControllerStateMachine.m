//
//  EPQuestionsTableViewControllerStateMachine.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import "EPQuestionsTableViewControllerStateMachine.h"

@interface EPQuestionsTableViewControllerStateMachine ()

@property (nonatomic,weak) id<EPQuestionsTableViewControllerStateMachineDelegateProtocol> delegate;

@end

@implementation EPQuestionsTableViewControllerStateMachine

- (id)initWithDelegate:(id<EPQuestionsTableViewControllerStateMachineDelegateProtocol>)delegate
{
    if ((self = [super init])) {
        _delegate = delegate;
    }
    return self;
}

@end
