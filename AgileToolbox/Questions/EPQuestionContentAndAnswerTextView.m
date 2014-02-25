//
//  EPContentTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import "EPQuestionContentAndAnswerTextView.h"

@implementation EPQuestionContentAndAnswerTextView

+ (NSAttributedString*)attributedHeaderTextFromText:(NSString*)text
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleBody];
    UIFont* contentFont = [UIFont fontWithDescriptor:contentFontDescriptor size:0];
    
    return [[NSAttributedString alloc] initWithString:text
                                           attributes: @{ NSFontAttributeName: contentFont,
                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
    
}

- (id)initWithText:(NSString*)text
{
    return [super initWithAttributedText:[EPQuestionContentAndAnswerTextView attributedHeaderTextFromText:text]];
}

// for some reason - this does not work reliably - creating new textView seems to be the only
// reliable way
- (void)updateFontSize
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleBody];
    UIFont* contentFont = [UIFont fontWithDescriptor:contentFontDescriptor size:0];
    
    self.font = contentFont;
    
    [super updateFontSize];
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
