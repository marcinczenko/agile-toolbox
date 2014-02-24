//
//  EPAttributedTextTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import "EPAttributedTextTableViewCell.h"
#import "EPQuestionsTableViewExpert.h"

@interface EPAttributedTextTableViewCell ()

@end

@implementation EPAttributedTextTableViewCell

- (id)initWithTextView:(UITextView*)textView
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        [self addSubviews:textView];
    }
    
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    NSAttributedString* as = self.myTextView.attributedText;
//    
//    CGRect rect2 = CGRectMake(5, 0, self.myTextView.textContainer.size.width, self.myTextView.textContainer.size.height);
//    
//    NSLog(@"rect:%@",NSStringFromCGRect(rect));
//    NSLog(@"rect2:%@",NSStringFromCGRect(rect2));
//    
//    [as drawWithRect:rect2 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addSubviews:(UITextView*)textView
{
    UIView* wrapperView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, textView.frame.size.height)];
    
    wrapperView.backgroundColor = [UIColor whiteColor];
    [self addSubview:wrapperView];
    [self addSubview:textView];
    
}

@end
