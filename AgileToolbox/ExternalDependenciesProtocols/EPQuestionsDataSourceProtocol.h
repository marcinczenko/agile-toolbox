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

@property (nonatomic,readonly) NSUInteger length;
@property (nonatomic,readonly) BOOL hasMoreQuestionsToFetch;

//- (void)downloadData;
- (NSString*)questionAtIndex:(NSUInteger)index;

- (void)setDelegate:(id<EPQuestionsDataSourceDelegateProtocol>)delegate;

- (void)fetch;
- (void)fetchNew;

@end
