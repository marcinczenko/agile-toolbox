//
//  EPDataSourceDelegateProtocol.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/9/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPQuestionsDataSourceDelegateProtocol <NSObject>

//- (void)dataSourceWillUpdate;
//- (void)dataSourceInsertedObject:(id)anObject atIndex:(NSInteger)index;
//- (void)dataSourceDidUpdate;
//- (void)mergeContext:(NSManagedObjectContext*)context;

- (void)fetchReturnedNoData;

@end
