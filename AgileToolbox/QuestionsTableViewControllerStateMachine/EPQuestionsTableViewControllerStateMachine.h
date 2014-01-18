//
//  EPQuestionsTableViewControllerStateMachine.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/01/14.
//
//

#import <Foundation/Foundation.h>

#import "EPQuestionsTableViewControllerStateMachineDelegateProtocol.h"
#import "EPQuestionsTableViewControllerState.h"

@interface EPQuestionsTableViewControllerStateMachine : NSObject

@property (nonatomic,weak,readonly) id<EPQuestionsTableViewControllerStateMachineDelegateProtocol> delegate;
@property (nonatomic,strong) EPQuestionsTableViewControllerState *state;

- (id)initWithDelegate:(id<EPQuestionsTableViewControllerStateMachineDelegateProtocol>)delegate;

@end
