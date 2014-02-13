//
//  EPQuestionTableViewCell.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 03/01/14.
//
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface EPQuestionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *updated;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorSlotLeft;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorSlotRight;

@property (assign,nonatomic) BOOL markedAsNew;
@property (assign,nonatomic) BOOL markedAsAnswered;

@property (readonly, nonatomic) UIImage* markerNewOrUpdated;
@property (readonly, nonatomic) UIImage* markerAnswered;

@property (readonly, nonatomic) NSDate* currentDate;

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andQuestion:(Question*)question;

- (void)formatCellForQuestion:(Question*)question;

- (void)setupUpdatedFieldUpdateTimer;

@end
