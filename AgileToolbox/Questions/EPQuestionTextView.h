//
//  EPQuestionTextView.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 14/02/14.
//
//

#import <UIKit/UIKit.h>

@interface EPQuestionTextView : UITextView

- (id)initWithAttributedText:(NSAttributedString*)attributedText;

- (void)updateFontSize;

@end
