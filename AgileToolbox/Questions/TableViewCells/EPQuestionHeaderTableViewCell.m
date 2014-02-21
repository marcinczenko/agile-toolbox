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
@property (nonatomic,strong) UILabel* label;

@end

@implementation EPQuestionHeaderTableViewCell


+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withTextField:(UITextField*)textField
{
    EPQuestionHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"QuestionHeaderTableViewCell"
                                                                                forIndexPath:indexPath];
    
    [headerCell addTextField:textField];
    
    return headerCell;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addHeaderLabel];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addHeaderLabel
{
    UIFont* headerFont = [UIFont systemFontOfSize:12];
    
    NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:@"Header: "
                                                                         attributes: @{ NSFontAttributeName: headerFont,
                                                                                        NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    self.label = [UILabel new];
    
    self.label.attributedText = attributedText;
    
    [self.label sizeToFit];
}

- (void) alignBaselines
{
    CGRect changedFrame = self.textField.frame;
    changedFrame.origin.y = ceilf(self.label.frame.origin.y + (self.label.font.ascender - self.textField.font.ascender));
    self.textField.frame = changedFrame;
}

- (void)addTextField:(UITextField*)textField
{
    if (!self.textField) {
        self.textField = textField;
        self.textField.frame = CGRectMake(15, 7, 218, 30);
        self.textField.font = [UIFont systemFontOfSize:14];
        
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        self.textField.leftView = self.label;
        
        [self addSubview:self.textField];
    }
}

@end
