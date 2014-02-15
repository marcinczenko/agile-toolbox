//
//  EPQuestionTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import "EPQuestionTextView.h"

@implementation EPQuestionTextView

+ (CGRect)rectForAttributedText:(NSAttributedString*)attributedText
{
    CGFloat width = 280;
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               context:nil];
    
    rect.size.height = ceil(rect.size.height);
    rect.size.width = ceil(rect.size.width);
    
    rect.size.width += 10.0;
    rect.size.height += 18.0;
    
    return CGRectOffset(rect, 10, 0);
}

- (id)initWithAttributedText:(NSAttributedString*)attributedText
{
    CGRect rect = [EPQuestionTextView rectForAttributedText:attributedText];
    
    // this has to be done here - after passing textContainer to initWithFram:textContainer below
    // the stack will be retained by the UITextView
    NSLayoutManager* layoutManager = [NSLayoutManager new];
    NSTextStorage* textStorage = [NSTextStorage new];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:rect.size];
    [layoutManager addTextContainer:textContainer];
    
    self = [super initWithFrame:rect textContainer:textContainer];
    if (self) {
        self.attributedText = attributedText;
        self.scrollEnabled = NO;
        self.editable = NO;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
