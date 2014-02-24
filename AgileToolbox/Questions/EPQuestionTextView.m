//
//  EPQuestionTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import "EPQuestionTextView.h"

@interface EPQuestionTextView ()

@end

@implementation EPQuestionTextView

- (id)initWithAttributedText:(NSAttributedString*)attributedText
{
    // this has to be done here - after passing textContainer to initWithFram:textContainer below
    // the stack will be retained by the UITextView
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager* layoutManager = [NSLayoutManager new];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(280, CGFLOAT_MAX)];
    [layoutManager addTextContainer:textContainer];
    
    self = [super initWithFrame:CGRectMake(10, 0, 300, 0) textContainer:textContainer];
    if (self) {
        self.scrollEnabled = NO;
        self.editable = NO;
        [self sizeToFit];
    }
    return self;
}

- (void)sizeToFit
{
//    NSLog(@"Frame[BEFORE]:%@",NSStringFromCGRect(self.frame));
    [super sizeToFit];
    
    if (self.frame.size.width != 300) {
        CGRect frame = self.frame;
        frame.size.width = 300;
        frame.origin = CGPointMake(10, 0);
        self.frame = frame;
    }
//    NSLog(@"Frame[AFTER]:%@",NSStringFromCGRect(self.frame));
}

- (void)updateFontSize
{
    [self sizeToFit];
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
