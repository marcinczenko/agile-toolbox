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

+ (id)cellDequeuedFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andQuestion:(Question*)question
{
    EPQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QATQuestionsAndAnswersCell"
                                                                            forIndexPath:indexPath];
    questionCell.textLabel.text = question.content;
    
    return questionCell;
}

@end
