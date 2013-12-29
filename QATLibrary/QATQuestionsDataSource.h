//
//  QATQuestionsDataSource.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QATConnectionProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface QATQuestionsDataSource : NSObject<EPQuestionsDataSourceProtocol,QATConnectionDelegateProtocol>

@property (nonatomic,readonly) NSInteger length;
@property (nonatomic,readonly) NSString* connectionURL;
@property (nonatomic,strong,readonly) id<QATConnectionProtocol> connection;

- (id)initWithConnection:(id<QATConnectionProtocol>)connection;
- (void)downloadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

#pragma mark - QATConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data;


@end
