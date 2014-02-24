//
//  EPSnapshot.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/02/14.
//
//

#import <Foundation/Foundation.h>

@interface EPSnapshot : NSObject<NSCoding>

@property (nonatomic,readonly) UIImage* image;
@property (nonatomic,readonly) BOOL hasImage;
@property (nonatomic,readonly) BOOL isImageFresh;

+ (UIImageView*)imageViewFromImage:(UIImage*)image withFrame:(CGRect)frame;
+ (UIImage*)createSnapshotOfView:(UIView*)view;
+ (UIImage*)createSnapshotOfView:(UIView*)view afterScreenUpdates:(BOOL)afterScreenUpdates;
+ (UIImage*) remove:(CGFloat)height fromTopOfImage:(UIImage*) image;
+ (UIImage*)createSnapshotForTableViewFrom:(UITableViewController*)viewController;

- (instancetype)initWithImage:(UIImage*)image;
- (CGPoint)computeSnapshotOriginInView:(id)view;
- (void)displayInView:(UIView*)view withTag:(NSInteger)tag originComputationBlock:(CGPoint(^)())block;
- (void)clear;
- (void)removeViewWithTag:(NSInteger)tag fromSuperview:(UIView*)superview;
- (void)writeAsJpgToFile:(NSString*)fileName;

@end
