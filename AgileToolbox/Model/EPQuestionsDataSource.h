//
//  EPQuestionsDataSource.h
//  AgileToolbox
//
//  Created by AtrBea on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "EPConnectionProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPQuestionsDataSourceProtocol.h"

@interface EPQuestionsDataSource : NSObject<EPQuestionsDataSourceProtocol,EPConnectionDelegateProtocol>

#pragma mark EPQuestionsDataSourceProtocol
@property (nonatomic,readonly) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> delegate;
- (void)fetchOlderThan:(NSInteger)questionId;
- (void)fetchNew;

#pragma mark - EPConnectionDelegateProtocol
- (void)downloadCompleted:(NSData *)data;

#pragma mark - EPQuestionsDataSource additional public interface
@property (nonatomic,readonly) NSString* connectionURL;
@property (nonatomic,readonly) id<EPConnectionProtocol> connection;

+ (NSUInteger)pageSize;

- (id)initWithConnection:(id<EPConnectionProtocol>)connection andWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;


#pragma mark - only for testing purposes - do not call these methods directly
- (void)saveToCoreData:(NSArray*)questionsArray;
@end
