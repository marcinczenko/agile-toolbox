//
//  EPQuestionTextView.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import <UIKit/UIKit.h>

@interface EPQuestionTextView : UITextView

+ (CGRect)contentSizeRectForTextView:(UITextView *)textView;

- (id)initWithAttributedText:(NSAttributedString*)attributedText;

@end
