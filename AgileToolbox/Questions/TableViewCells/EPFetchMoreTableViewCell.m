//
//  EPFetchMoreTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 02/01/14.
//
//

#import "EPFetchMoreTableViewCell.h"

@implementation EPFetchMoreTableViewCell

static const NSString *cellId = @"FetchMore";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath loading:(BOOL)status
{
    EPFetchMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                      forIndexPath:indexPath];
    cell.tableView = tableView;
    cell.backgroundColor = [UIColor colorWithRed:0.937 green:0.255 blue:0.165 alpha:1.0];
    [cell hideSeparatorLine];
    [cell setLoadingStatus:status];
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideSeparatorLine
{
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.bounds.size.width);
}

- (void)setLoadingStatus:(BOOL)status
{
    if (status) {
        self.label.hidden = YES;
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
        self.label.hidden = NO;
    }
}

@end
