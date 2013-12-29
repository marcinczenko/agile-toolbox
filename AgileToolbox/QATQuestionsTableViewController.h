//
//  QATQuestionsTableViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPQuestionsDataSourceProtocol.h"
#import "EPQuestionsDataSourceDelegateProtocol.h"
#import "QATAddQuestionDelegateProtocol.h"

#import "QATPostmanProtocol.h"
#import "QATPostmanDelegateProtocol.h"

@interface QATQuestionsTableViewController : UITableViewController<EPQuestionsDataSourceDelegateProtocol,QATAddQuestionDelegateProtocol,QATPostmanDelegateProtocol>

@property (nonatomic,strong) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,strong) id<QATPostmanProtocol> postman;

@end
