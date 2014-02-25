//
//  EPPostmanProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPPostmanDelegateProtocol.h"

@protocol EPPostmanProtocol <NSObject>

@property (nonatomic,assign) id<EPPostmanDelegateProtocol> delegate;

- (void)post:(NSString*)item;
- (void)postQuestionWithHeader:(NSString*)header content:(NSString*)content;

@end
