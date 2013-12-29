//
//  EPPostmanDelegateProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPPostmanDelegateProtocol <NSObject>

- (void)postDelivered;
- (void)postDeliveryFailed;

@end
