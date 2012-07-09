//
//  QATQuestionsDataSource.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATConnectionProtocol.h"
#import "QATConnectionDelegateProtocol.h"
#import "QATDataSourceProtocol.h"

@interface QATQuestionsDataSource : NSObject<QATDataSourceProtocol,QATConnectionDelegateProtocol>

@property (readonly) NSInteger length;

- (id)initWithConnection:(id<QATConnectionProtocol>)connection;
- (void)loadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

#pragma mark - QATConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data;


@end
