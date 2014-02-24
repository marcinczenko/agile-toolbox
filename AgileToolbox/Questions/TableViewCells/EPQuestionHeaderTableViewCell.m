//
//  EPQuestionHeaderTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import "EPQuestionHeaderTableViewCell.h"

@interface EPQuestionHeaderTableViewCell ()

@property (nonatomic,weak) UITextField* textField;

@end

@implementation EPQuestionHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (id)initWithTextField:(UITextField*)textField
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        _textField = [self addTextField:textField];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel*)addHeaderLabel
{
    UIFont* headerFont = [UIFont systemFontOfSize:12];
    
    NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:@"Header: "
                                                                         attributes: @{ NSFontAttributeName: headerFont,
                                                                                        NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    UILabel* label = [UILabel new];
    label.attributedText = attributedText;
    [label sizeToFit];
    
    return label;
}

- (UITextField*)addTextField:(UITextField*)textField
{
    textField.frame = CGRectMake(15, 7, 218, 30);
    textField.font = [UIFont systemFontOfSize:16];
    
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = [self addHeaderLabel];
    
    [self.contentView addSubview:textField];
    
    return textField;
}

@end
