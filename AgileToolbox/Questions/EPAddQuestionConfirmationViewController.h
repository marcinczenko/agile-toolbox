//
//  EPAddQuestionConfirmationViewController.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 22/02/14.
//
//

#import <UIKit/UIKit.h>
#import "EPSnapshot.h"
#import "EPPostmanProtocol.h"
#import "EPPostmanDelegateProtocol.h"

@interface EPAddQuestionConfirmationViewController : UIViewController<EPPostmanDelegateProtocol>

@property (nonatomic,strong) EPSnapshot* snapshot;
@property (nonatomic,weak) id<EPPostmanProtocol> postman;

@end
