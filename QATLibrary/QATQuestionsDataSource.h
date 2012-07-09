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

@interface QATQuestionsDataSource : NSObject<QATConnectionDelegateProtocol>

@property (readonly) NSInteger length;

//+ (id)questionsDataSourceFromJSONData:(NSData*)data;

- (id)initWithConnection:(id<QATConnectionProtocol>)connection;
- (void)loadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

- (void)downloadCompleted:(NSData *)data;


@end
