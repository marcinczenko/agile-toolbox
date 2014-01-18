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

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath
{
    EPFetchMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FetchMore"
                                      forIndexPath:indexPath];
    cell.tableView = tableView;
    [cell hideSeparatorLine];
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


@end
