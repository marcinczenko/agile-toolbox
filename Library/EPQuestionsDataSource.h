//
//  EPQuestionsDataSource.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPConnectionProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface EPQuestionsDataSource : NSObject<EPQuestionsDataSourceProtocol,EPConnectionDelegateProtocol>

@property (nonatomic,readonly) NSUInteger length;
@property (nonatomic,readonly) NSString* connectionURL;
@property (nonatomic,strong,readonly) id<EPConnectionProtocol> connection;

- (id)initWithConnection:(id<EPConnectionProtocol>)connection;
- (void)downloadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

#pragma mark - EPConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data;


@end
