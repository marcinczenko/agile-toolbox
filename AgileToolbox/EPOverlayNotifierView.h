//
//  EPOverlayNotifierView.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 15/02/14.
//
//

#import <UIKit/UIKit.h>

@interface EPOverlayNotifierView : UILabel

+ (NSInteger)tagValue;

- (id)initWithTableViewFrame:(CGRect)frame;

- (void) addToView:(UIView*)view for:(NSTimeInterval)duration;

@end
