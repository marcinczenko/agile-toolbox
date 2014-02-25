//
//  EPQuestionUpdatedTextView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 19/02/14.
//
//

#import "EPQuestionUpdatedTextView.h"

@implementation EPQuestionUpdatedTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSAttributedString*)attributedTextFromText:(NSString*)text
{
    UIFont* headerFont = [UIFont fontWithName:@"Helvetica-Light" size:10];
    
    return [[NSAttributedString alloc] initWithString:text
                                           attributes: @{ NSFontAttributeName: headerFont,
                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
    
}

- (id)initWithText:(NSString*)text
{
    return [super initWithAttributedText:[EPQuestionUpdatedTextView attributedTextFromText:text]];
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
