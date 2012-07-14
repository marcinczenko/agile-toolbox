//
//  QATAddQuestionViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QATAddQuestionDelegateProtocol.h"

@interface QATAddQuestionViewController : UIViewController

@property (nonatomic,assign) id<QATAddQuestionDelegateProtocol> delegate;

@property (weak, nonatomic) IBOutlet UITextField *addedQuestionText;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
