//
//  EPQuestionsTableViewControllerQuestionsConnectionFailureState.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import "EPQuestionsTableViewControllerQuestionsConnectionFailureState.h"

@implementation EPQuestionsTableViewControllerQuestionsConnectionFailureState

- (UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.section) {
        return [super cellForRowAtIndexPath:indexPath];
    } else {
        EPFetchMoreTableViewCell* fetchMoreCell = (EPFetchMoreTableViewCell*)[super cellForRowAtIndexPath:indexPath];
        fetchMoreCell.label.text = @"Connection failure. Pull up to try again.";
        return fetchMoreCell;
    }
}

@end
