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

#import "QATPostmanProtocol.h"
#import "QATPostmanDelegateProtocol.h"

@interface QATQuestionsTableViewController : UITableViewController<QATDataSourceDelegateProtocol,QATAddQuestionDelegateProtocol,QATPostmanDelegateProtocol>

@property (nonatomic,strong) id<QATDataSourceProtocol> questionsDataSource;
@property (nonatomic,strong) id<QATPostmanProtocol> postman;

@end
