//
//  EPDataSourceDelegateProtocol.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/9/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPQuestionsDataSourceDelegateProtocol <NSObject>

- (void)fetchReturnedNoData;
- (void)fetchReturnedNoDataInBackground;
- (void)dataChangedInBackground;
- (void)connectionFailure;
- (void)connectionFailureInBackground;

@end
