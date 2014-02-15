//
//  EPQuestionDetailsTableViewController.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface EPQuestionDetailsTableViewController : UITableViewController

@property (nonatomic,weak) Question* question;

@property (nonatomic,copy,readonly) NSString* questionHeader;
@property (nonatomic,copy,readonly) NSString* questionContent;
@property (nonatomic,copy,readonly) NSString* questionAnswer;
@property (nonatomic,copy,readonly) NSDate* questionUpdated;

@end
