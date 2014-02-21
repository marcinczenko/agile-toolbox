//
//  EPQuestionTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import "EPQuestionTextView.h"

@interface EPQuestionTextView ()

//@property (nonatomic,strong) NSLayoutManager* layoutManager;
//@property (nonatomic,strong) NSTextStorage* textStorage;
//@property (nonatomic,strong) NSTextContainer* textContainer;


@end

@implementation EPQuestionTextView

+ (CGRect)rectForAttributedText:(NSAttributedString*)attributedText
{
    CGFloat width = 280;
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               context:nil];
    
    rect.size.height = ceil(rect.size.height);
    rect.size.width = ceil(rect.size.width);
    
//    rect.size.width += 10.0;
//    rect.size.height += 18.0;
    
    return CGRectOffset(rect, 10, 0);
}

+ (CGRect)contentSizeRectForTextView:(UITextView *)textView
{
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
    CGRect textBounds = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
    CGFloat width =  (CGFloat)ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right);
    CGFloat height = (CGFloat)ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom);
    return CGRectMake(0, 0, width, height);
}

- (id)initWithAttributedText:(NSAttributedString*)attributedText
{
    CGRect rect = [EPQuestionTextView rectForAttributedText:attributedText];
    
    // this has to be done here - after passing textContainer to initWithFram:textContainer below
    // the stack will be retained by the UITextView
    
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager* layoutManager = [NSLayoutManager new];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:rect.size];
    [layoutManager addTextContainer:textContainer];
    
    self = [super initWithFrame:CGRectMake(10, 0, 300, 0) textContainer:textContainer];
    if (self) {
        [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
        [self layoutIfNeeded];
        
        CGRect actual_rect = [self.class contentSizeRectForTextView:self];
        
        self.frame = CGRectMake(10, 0, 300, actual_rect.size.height);
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
