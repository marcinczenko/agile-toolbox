//
//  QATSmartTableViewCell.h
//  AgileToolbox
//
//  Created by AtrBea on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QATSmartTableViewCell : UITableViewCell

+ (id)cellForTableView:(UITableView*)tableView;
+ (NSString*)cellIdentifier;

- (id)initWithCellIdentifier:(NSString*)cellID;


@end
