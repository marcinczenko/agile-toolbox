//
//  EPQuestionsDataSourceProtocol.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 28/12/13.
//
//

#import <Foundation/Foundation.h>
#import "EPQuestionsDataSourceDelegateProtocol.h"

@protocol EPQuestionsDataSourceProtocol <NSObject>

@property (nonatomic,readonly) BOOL hasMoreQuestionsToFetch;
@property (nonatomic,assign) BOOL backgroundFetchMode;
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> delegate;

- (void)storeToPersistentStorage;
- (void)restoreFromPersistentStorage;

- (void)fetchOlderThan:(NSInteger)questionId;
- (void)fetchNewAndUpdatedGivenMostRecentQuestionId:(NSInteger)mostRecentQuestionId andOldestQuestionId:(NSInteger)oldestQuestionId;

@end
