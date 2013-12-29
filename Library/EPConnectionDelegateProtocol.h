//
//  EPConnectionDelegateProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPConnectionDelegateProtocol <NSObject>

- (void) downloadCompleted:(NSData*)data;

@end
