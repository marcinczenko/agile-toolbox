//
//  EPQuestionsTableViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "EPAddQuestionDelegateProtocol.h"

#import "EPPostmanProtocol.h"
#import "EPPostmanDelegateProtocol.h"

@interface EPQuestionsTableViewController : UITableViewController<EPQuestionsDataSourceDelegateProtocol,EPAddQuestionDelegateProtocol,EPPostmanDelegateProtocol>

@property (nonatomic,strong) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,strong) id<EPPostmanProtocol> postman;

@end
