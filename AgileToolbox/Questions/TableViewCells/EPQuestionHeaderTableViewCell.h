//
//  EPQuestionHeaderTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import <UIKit/UIKit.h>

@interface EPQuestionHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *questionHeader;

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withTextField:(UITextField*)textField;

@end
