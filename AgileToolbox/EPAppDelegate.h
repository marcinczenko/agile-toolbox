//
//  EPAppDelegate.h
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPQuestionsDataSource.h"
#import "EPQuestionPostman.h"

@interface EPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) EPQuestionsDataSource* questionsDataSource;
@property (strong, nonatomic, readonly) EPQuestionPostman* postman;

@end
