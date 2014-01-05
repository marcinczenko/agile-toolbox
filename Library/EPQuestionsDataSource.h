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
@property (nonatomic,readonly) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,readonly) NSString* connectionURL;
@property (nonatomic,strong,readonly) id<EPConnectionProtocol> connection;
@property (nonatomic,assign,readonly) NSUInteger currentPageNumber;
@property (nonatomic,assign,readonly) NSUInteger questionsPerPage;
@property (nonatomic,assign,readonly) NSUInteger nextPageIndexTreshold;

+ (NSUInteger)pageSize;

- (id)initWithConnection:(id<EPConnectionProtocol>)connection;
- (void)fetch;
- (void)fetchNew;
- (NSString*)questionAtIndex:(NSUInteger)index;
- (void)setDelegate:(id<EPQuestionsDataSourceDelegateProtocol>)delegate;

#pragma mark - EPConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data;


@end
