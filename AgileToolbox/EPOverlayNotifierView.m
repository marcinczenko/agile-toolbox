//
//  EPOverlayNotifierView.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 15/02/14.
//
//

#import "EPOverlayNotifierView.h"

@implementation EPOverlayNotifierView

+ (NSInteger)tagValue
{
    return 1502140032;
}

+ (CGRect)frameFromTableViewFrame:(CGRect)tableViewFrame
{
    CGRect frame = tableViewFrame;
    frame.origin.y = tableViewFrame.size.height-64.0;
    frame.size.height = 40.0;
    
    return frame;
}

- (id)initWithTableViewFrame:(CGRect)frame
{
    return [self initWithFrame:[EPOverlayNotifierView frameFromTableViewFrame:frame]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = [EPOverlayNotifierView tagValue];
        self.backgroundColor = [UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:0.9f];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont fontWithName:@"Helvetica-Light" size:12];
        self.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)keepVisibleFor:(double)duration completionBlock:(void (^)())block
{
    double delayInSeconds = duration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void) addToView:(UIView*)view for:(NSTimeInterval)duration
{
    
    CGPoint originalCenter = self.center;
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y-40.0);
    }];
    
    [self keepVisibleFor:duration completionBlock:^{
        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            self.center = originalCenter;
        }];
    }];
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
