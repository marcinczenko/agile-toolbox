//
//  QATDataSourceProtocol.h
//  AgileToolbox
//
//  Created by AtrBea on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QATDataSourceDelegateProtocol.h"

@protocol QATDataSourceProtocol <NSObject>

@property (nonatomic,readonly) NSInteger length;

- (void)downloadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

- (void)setDelegate:(id<QATDataSourceDelegateProtocol>)delegate;

@end
