//
//  EPQuestionTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 03/01/14.
//
//

#import "EPQuestionTableViewCell.h"
#import "EPTimeIntervalFormatter.h"

@interface EPQuestionTableViewCell ()

@property (strong, nonatomic) NSDate* updatedNSDate;

@property (nonatomic, strong) NSTimer *updateTimer;


@end

@implementation EPQuestionTableViewCell

@synthesize markedAsNew = _markedAsNew;
@synthesize markedAsAnswered = _markedAsAnswered;

+ (UIColor*)colorNew
{
    return [UIColor colorWithRed:41.0/255.0 green:171.0/255.0 blue:226.0/255.0 alpha:1.0];
}

+ (UIColor*)colorAnswered
{
    return [UIColor colorWithRed:0.0 green:146.0/255.0 blue:69.0/255.0 alpha:1.0];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUpdatedFieldUpdateTimer];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUpdatedFieldUpdateTimer
{
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                        target:self
                                                      selector:@selector(updateTimerHandler:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)updateTimerHandler:(NSTimer*)sender
{
    self.updated.text = [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:self.updatedNSDate toDate:[NSDate date]];
}

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andQuestion:(Question*)question
{
    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                            forIndexPath:indexPath];
    
    [questionCell formatCellForQuestion:question];
    
    return questionCell;
}

- (UIImage*)drawCircle:(UIColor*) color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(15,15), NO, 0);
    UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,15,15)];
    [color setFill];
    [circle fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)markerNewOrUpdated
{
    static UIImage* imageForNewOrUpdated = nil;
    
    if (nil == imageForNewOrUpdated) {
        imageForNewOrUpdated = [self drawCircle:[self.class colorNew]];
    }
    
    return imageForNewOrUpdated;
}

- (UIImage*)markerAnswered
{
    static UIImage* imageAnswered = nil;
    
    if (nil == imageAnswered) {
        imageAnswered = [self drawCircle:[self.class colorAnswered]];
    }
    
    return imageAnswered;
}


- (void)updateMarkers
{
    if (self.markedAsNew && self.markedAsAnswered) {
        self.indicatorSlotLeft.image = self.markerNewOrUpdated;
        self.indicatorSlotRight.image = self.markerAnswered;
        
    } else if (self.markedAsNew) {
        self.indicatorSlotLeft.image = self.markerNewOrUpdated;
        self.indicatorSlotRight.image = nil;
    } else if (self.markedAsAnswered) {
        self.indicatorSlotLeft.image = self.markerAnswered;
        self.indicatorSlotRight.image = nil;
    } else {
        self.indicatorSlotLeft.image = nil;
        self.indicatorSlotRight.image = nil;
    }
}

- (BOOL)markedAsNew
{
    return _markedAsNew;
}

- (void)setMarkedAsNew:(BOOL)status
{
    _markedAsNew = status;
    
    [self updateMarkers];
}

- (BOOL)markedAsAnswered
{
    return _markedAsAnswered;
}

- (void)setMarkedAsAnswered:(BOOL)status
{
    _markedAsAnswered = status;
    
    [self updateMarkers];
}

- (UIFont*)getPreferredFontWithTextStyle:(NSString*)textStyle
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
    return [UIFont fontWithDescriptor:contentFontDescriptor size:0];
}

- (UIFont*)getPreferredFontForQuestionHeader
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleHeadline];
    return [UIFont fontWithDescriptor:contentFontDescriptor size:0];
}


- (void)formatCellForQuestion:(Question*)question
{
    self.updatedNSDate = question.updated;
    
    self.header.font = [self getPreferredFontWithTextStyle:UIFontTextStyleHeadline];
    self.header.text = question.header;    
    
    self.content.font = [self getPreferredFontWithTextStyle:UIFontTextStyleSubheadline];
    
    self.content.text = question.content;
    
    self.updated.font = [self getPreferredFontWithTextStyle:UIFontTextStyleFootnote];
    self.updated.text = [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:self.updatedNSDate toDate:[NSDate date]];
    
    self.markedAsNew = question.updatedOrNew.boolValue;
    
    if (0<question.answer.length) {
        self.markedAsAnswered = YES;
    } else {
        self.markedAsAnswered = NO;
    }
}

@end
