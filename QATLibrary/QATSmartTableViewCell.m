//
//  QATSmartTableViewCell.m
//  AgileToolbox
//
//  Created by AtrBea on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATSmartTableViewCell.h"

@implementation QATSmartTableViewCell

+ (id) cellForTableView:(UITableView *)tableView
{
    NSString *cellID = [self cellIdentifier];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (nil == cell) {
        cell = [[self alloc] initWithCellIdentifier:cellID];
    }
    
    return cell;
}

+ (NSString*)cellIdentifier
{
    return NSStringFromClass([self class]);
}

- (id)initWithCellIdentifier:(NSString *)cellID
{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
}

@end
