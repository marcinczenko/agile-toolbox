//
//  EPHeaderTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import "EPQuestionHeaderTextView.h"

@implementation EPQuestionHeaderTextView

+ (NSAttributedString*)attributedHeaderTextFromText:(NSString*)text
{
    UIFont* headerFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    
    return [[NSAttributedString alloc] initWithString:text
                                           attributes: @{ NSFontAttributeName: headerFont,
                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
            
}

- (id)initWithText:(NSString*)text
{
    return [super initWithAttributedText:[EPQuestionHeaderTextView attributedHeaderTextFromText:text]];
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
