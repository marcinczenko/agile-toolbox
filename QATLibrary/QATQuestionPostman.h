//
//  QATQuestionPostman.h
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATConnectionDelegateProtocol.h"
#import "QATConnectionProtocol.h"
#import "QATPostmanDelegateProtocol.h"
#import "QATPostmanProtocol.h"

@interface QATQuestionPostman : NSObject<QATPostmanProtocol,QATConnectionDelegateProtocol>

@property (nonatomic,assign) id<QATPostmanDelegateProtocol> delegate;

- (id)initWithConnection:(id<QATConnectionProtocol>)connection;

- (void)post:(NSString*)item;

@end
