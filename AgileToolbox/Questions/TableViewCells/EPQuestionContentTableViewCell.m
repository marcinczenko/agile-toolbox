//
//  EPQuestionContentTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import "EPQuestionContentTableViewCell.h"

@interface EPQuestionContentTableViewCell ()


@property (nonatomic,weak) UITableView* tableView;

@end

@implementation EPQuestionContentTableViewCell

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath
{
    EPQuestionContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionContentTableViewCell"
                                                                                forIndexPath:indexPath];
    
    return cell;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier textView:(UITextView*)textView
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _textView = textView;
        [self addSubview:textView];
        // hide separator inset for this cell
        self.separatorInset = UIEdgeInsetsMake(0, 568, 0, 0);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
