//
//  QATQuestionsTableViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QATDataSourceProtocol.h"
#import "QATDataSourceDelegateProtocol.h"
#import "QATAddQuestionDelegateProtocol.h"

@interface QATQuestionsTableViewController : UITableViewController<QATDataSourceDelegateProtocol,QATAddQuestionDelegateProtocol>

@property (nonatomic,strong) id<QATDataSourceProtocol> questionsDataSource;

@end
