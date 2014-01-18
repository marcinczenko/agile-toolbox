//
//  EPFetchMoreTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 02/01/14.
//
//

#import <UIKit/UIKit.h>

@interface EPFetchMoreTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,weak) IBOutlet UILabel *label;

@property (nonatomic,weak) UITableView *tableView;

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;


@end
