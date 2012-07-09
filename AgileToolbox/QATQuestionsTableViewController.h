//
//  QATQuestionsTableViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QATDataSourceProtocol.h"

@interface QATQuestionsTableViewController : UITableViewController

@property (nonatomic,strong) id<QATDataSourceProtocol> questionsDataSource;

@end
