//
//  EPAttributedTextTableViewCell.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import "EPAttributedTextTableViewCell.h"
#import "EPQuestionsTableViewExpert.h"

@interface EPAttributedTextTableViewCell ()



@end

@implementation EPAttributedTextTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    NSAttributedString* as = self.myTextView.attributedText;
//    
//    CGRect rect2 = CGRectMake(5, 0, self.myTextView.textContainer.size.width, self.myTextView.textContainer.size.height);
//    
//    NSLog(@"rect:%@",NSStringFromCGRect(rect));
//    NSLog(@"rect2:%@",NSStringFromCGRect(rect2));
//    
//    [as drawWithRect:rect2 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)cellDequeuedFromTableView:(UITableView*)tableView
                   forIndexPath:(NSIndexPath*)indexPath
                  usingTextView:(UITextView*)textView
{
    EPAttributedTextTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AttributedTextTableViewCell"
                                                                          forIndexPath:indexPath];
    
    cell.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    
    UIView* wrapperView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, textView.textContainer.size.height)];
    
    switch (indexPath.row) {
        case 0:
            cell.backgroundColor = [UIColor grayColor];
            break;
        case 1:
            cell.backgroundColor = [UIColor yellowColor];
            break;
        case 2:
            cell.backgroundColor = [UIColor greenColor];
        default:
            break;
    }
    
    wrapperView.backgroundColor = [UIColor whiteColor];
    [cell addSubview:wrapperView];
    [cell addSubview:textView];
    
    return cell;
}

@end
