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
@property (nonatomic,weak) id<EPQuestionsDataSourceDelegateProtocol> delegate;


- (void)fetchOlderThan:(NSInteger)questionId;
- (void)fetchNew;

@end
