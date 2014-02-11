//
//  EPQuestionTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 03/01/14.
//
//

#import "EPQuestionTableViewCell.h"

@implementation EPQuestionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// TODO: remove Question parameter from this method and use formatCellForQuestion: instead
+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andQuestion:(Question*)question
{
    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                            forIndexPath:indexPath];
    questionCell.textLabel.text = question.content;
    
    return questionCell;
}

- (void)formatCellForQuestion:(Question*)question
{
    self.textLabel.text = question.content;
}

@end
