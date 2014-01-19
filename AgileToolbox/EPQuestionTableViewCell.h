//
//  EPQuestionTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 03/01/14.
//
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface EPQuestionTableViewCell : UITableViewCell

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andQuestion:(Question*)question;

@end
