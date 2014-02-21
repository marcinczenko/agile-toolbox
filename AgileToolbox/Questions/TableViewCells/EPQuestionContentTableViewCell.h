//
//  EPQuestionContentTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import <UIKit/UIKit.h>

@interface EPQuestionContentTableViewCell : UITableViewCell

@property (nonatomic,strong) UITextView* textView;

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier textView:(UITextView*)textView;

@end
