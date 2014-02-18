//
//  EPQuestionsRefreshControl.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 17/02/14.
//
//

#import "EPQuestionsRefreshControl.h"
#import "EPQuestionsTableViewController.h"

@implementation EPQuestionsRefreshControl

NSString* const EPQuestionsRefreshControlTextRefreshing = @"Refreshing...";
NSString* const EPQuestionsRefreshControlTextEnabled = @"Pull to Refresh...";
NSString* const EPQuestionsRefreshControlTextConnectionFailure = @"Connection Failure. Try again later.";

- (NSAttributedString*)attributedTextWithString:(NSString*)string
{
    UIFont* font = [UIFont fontWithName:@"Helvetica-Light" size:10];
    return [[NSAttributedString alloc] initWithString:string
                                           attributes: @{ NSFontAttributeName: font,
                                                          NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void)enable
{
    self.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextEnabled];
}

- (void)beginRefreshingWithBeforeBlock:(void(^)())beforeBlock afterBlock:(void(^)())afterBlock
{
//    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextRefreshing];
//    [refreshControl addTarget:self
//                       action:@selector(refresh:)
//             forControlEvents:UIControlEventValueChanged];
//    self.tableViewController.refreshControl = refreshControl;
    
    self.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextRefreshing];
    [super beginRefreshingWithBeforeBlock:beforeBlock afterBlock:afterBlock];
}

- (void)beginRefreshing
{
    self.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextRefreshing];
    
    [super beginRefreshing];
}

- (void)endRefreshing
{
    self.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextEnabled];
    
    [super endRefreshing];
}

- (void)connectionFailure
{
    self.attributedTitle = [self attributedTextWithString:EPQuestionsRefreshControlTextConnectionFailure];
    
    [super endRefreshing];
}



@end
