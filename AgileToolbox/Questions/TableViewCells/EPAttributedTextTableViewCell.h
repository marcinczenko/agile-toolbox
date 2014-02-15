//
//  EPAttributedTextTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface EPAttributedTextTableViewCell : UITableViewCell

@property (nonatomic,strong) UITextView* myTextView;

+ (id)cellDequeuedFromTableView:(UITableView*)tableView
                   forIndexPath:(NSIndexPath*)indexPath
                  usingTextView:(UITextView*)textView;


@end
