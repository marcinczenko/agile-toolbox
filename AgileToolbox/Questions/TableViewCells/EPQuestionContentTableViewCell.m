//
//  EPQuestionContentTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import "EPQuestionContentTableViewCell.h"

@interface EPQuestionContentTableViewCell ()

@end

@implementation EPQuestionContentTableViewCell

- (instancetype)initWithTextView:(UITextView*)textView
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        [self.contentView addSubview:textView];
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
