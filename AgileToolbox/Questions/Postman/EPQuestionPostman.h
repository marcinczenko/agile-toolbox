//
//  EPQuestionPostman.h
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPConnectionDelegateProtocol.h"
#import "EPConnectionProtocol.h"
#import "EPPostmanDelegateProtocol.h"
#import "EPPostmanProtocol.h"

@interface EPQuestionPostman : NSObject<EPPostmanProtocol,EPConnectionDelegateProtocol>

@property (nonatomic,assign) id<EPPostmanDelegateProtocol> delegate;

- (id)initWithConnection:(id<EPConnectionProtocol>)connection;

- (void)post:(NSString*)item;

@end
