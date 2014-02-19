//
//  EPSnapshot.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 18/02/14.
//
//

#import "EPSnapshot.h"

@interface EPSnapshot ()

@property (nonatomic,strong) UIImage* image;
@property (nonatomic,assign) BOOL isImageFresh;

@end

@implementation EPSnapshot

+ (UIImageView*)imageViewFromImage:(UIImage*)image withFrame:(CGRect)frame
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = image;
    
    return imageView;
}

+ (UIImage*)createSnapshotOfView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    UIImage* snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

+ (UIImage*) remove:(CGFloat)height fromTopOfImage:(UIImage*) image
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height-height), YES, 0);
    [image drawAtPoint:CGPointMake(0, -height)];
    UIImage* croppedSnapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedSnapshot;
}

+ (UIImage*)createSnapshotForTableViewFrom:(UITableViewController*)viewController
{
    CGFloat distanceFromTop = viewController.refreshControl.isRefreshing ? viewController.tableView.contentInset.top - viewController.refreshControl.frame.size.height : viewController.tableView.contentInset.top;
    
    return [self remove:distanceFromTop
         fromTopOfImage:[self createSnapshotOfView:viewController.tableView]];
}

- (instancetype)init
{
    return [self initWithImage:nil];
}

- (instancetype)initWithImage:(UIImage*)image
{
    self = [super init];
    
    if (self) {
        _image = image;
        if (image) {
            _isImageFresh = YES;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithImage:[[UIImage alloc] initWithCoder:aDecoder]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.image encodeWithCoder:aCoder];
}

- (BOOL)hasImage
{
    return (nil != self.image);
}

- (void)clear
{
    self.image = nil;
    _isImageFresh = NO;
}

- (CGPoint)computeSnapshotOriginInView:(id)view
{
    return CGPointMake(0, 0);
}

- (void)displayInView:(UIView*)view withTag:(NSInteger)tag originComputationBlock:(CGPoint(^)())block
{
    if (self.hasImage) {
        CGRect frame ;
        if (block) {
            frame.origin = block();
        } else {
            frame.origin = CGPointMake(0, 0);
        }
        frame.size = self.image.size;
        
        UIImageView* imageView = [self.class imageViewFromImage:self.image withFrame:frame];
        imageView.tag = tag;
        
        [view addSubview:imageView];
    }
}

- (void)removeViewWithTag:(NSInteger)tag fromSuperview:(UIView*)superview
{
    UIView* view = [superview viewWithTag:tag];
    
    view.hidden = YES;
    [view removeFromSuperview];
    self.isImageFresh = NO;
}

@end
