//
//  QATPostmanProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATPostmanDelegateProtocol.h"

@protocol QATPostmanProtocol <NSObject>

@property (nonatomic,assign) id<QATPostmanDelegateProtocol> delegate;

- (void)post:(NSString*)item;

@end
