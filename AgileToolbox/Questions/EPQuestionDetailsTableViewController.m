//
//  EPQuestionDetailsTableViewController.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 13/02/14.
//
//

#import "EPQuestionDetailsTableViewController.h"
#import "EPAttributedTextTableViewCell.h"

#import "EPQuestionsTableViewExpert.h"

#import "EPQuestionHeaderTextView.h"
#import "EPQuestionContentAndAnswerTextView.h"

#import "EPOverlayNotifierView.h"

#import "EPPersistentStoreHelper.h"

static NSString* const kQuestionHeader = @"Header";
static NSString* const kQuestionContent = @"Content";
static NSString* const kQuestionAnswer = @"Answer";
static NSString* const kQuestionUpdated = @"Updated";

@interface EPQuestionDetailsTableViewController ()

@property (nonatomic,strong) EPQuestionHeaderTextView* headerTextView;
@property (nonatomic,strong) EPQuestionContentAndAnswerTextView* contentTextView;
@property (nonatomic,strong) EPQuestionContentAndAnswerTextView* answerTextView;
@property (nonatomic,strong) EPOverlayNotifierView* updatedDateView;

@property (nonatomic,copy) NSString* questionHeader;
@property (nonatomic,copy) NSString* questionContent;
@property (nonatomic,copy) NSString* questionAnswer;
@property (nonatomic,copy) NSDate* questionUpdated;

@end

@implementation EPQuestionDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if ((self = [super initWithCoder:aDecoder])) {
//        [self decodeObjectWithCoder:aDecoder];
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    [self encodeObjectWithCoder:aCoder];
//}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [self encodeObjectWithCoder:coder];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [self decodeObjectWithCoder:coder];
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)applicationFinishedRestoringState
{
    if (!self.contentTextView) {
        [self configureView];
    }
}

- (void)decodeObjectWithCoder:(NSCoder *)aDecoder
{
    self.questionHeader = [aDecoder decodeObjectForKey:kQuestionHeader];
    self.questionContent = [aDecoder decodeObjectForKey:kQuestionContent];
    self.questionAnswer = [aDecoder decodeObjectForKey:kQuestionAnswer];
    self.questionUpdated = [aDecoder decodeObjectForKey:kQuestionUpdated];
}

- (void)encodeObjectWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.questionHeader forKey:kQuestionHeader];
    [aCoder encodeObject:self.questionContent forKey:kQuestionContent];
    [aCoder encodeObject:self.questionAnswer forKey:kQuestionAnswer];
    [aCoder encodeObject:self.questionUpdated forKey:kQuestionUpdated];
}


- (void)copyQuestion:(Question*)question
{
    self.questionHeader = question.header;
    self.questionContent = question.content;
    self.questionAnswer = question.answer;
    self.questionUpdated = question.updated;
}

- (void)setQuestion:(Question *)question
{
    _question = question;
    [self copyQuestion:question];
}

- (void)configureView
{
    if (self.questionContent) {
        [self setUpHeaderTextView];
        [self setUpContentTextView];
        [self setUpAnswerTextView];
        [self setUpUpdatedOverlayView];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.questionUpdated) {
        [self.updatedDateView addToView:self.view for:3.0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [EPAttributedTextTableViewCell cellDequeuedFromTableView:tableView
                                                               forIndexPath:indexPath
                                                              usingTextView:self.headerTextView];
        case 1:
            return [EPAttributedTextTableViewCell cellDequeuedFromTableView:tableView
                                                               forIndexPath:indexPath
                                                              usingTextView:self.contentTextView];
        case 2:
            return [EPAttributedTextTableViewCell cellDequeuedFromTableView:tableView
                                                               forIndexPath:indexPath
                                                              usingTextView:self.answerTextView];
        default:
            return nil;
    }
}

- (void)setUpHeaderTextView
{
    self.headerTextView = [[EPQuestionHeaderTextView alloc] initWithText:self.questionHeader];
}


- (void)setUpContentTextView
{
    self.contentTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:self.questionContent];
}

- (void)setUpAnswerTextView
{
    if (!self.question.answer || 0==self.question.answer.length) {
        self.answerTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:@"Awaiting answer..."];
    } else {
        self.answerTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:self.questionAnswer];
    }
}

- (NSString*)stringFromDate:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

- (void)setUpUpdatedOverlayView
{
    self.updatedDateView = [[EPOverlayNotifierView alloc] initWithTableViewFrame:self.view.frame];
    self.updatedDateView.text = [NSString stringWithFormat:@"Last updated on %@",[self stringFromDate:self.questionUpdated]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return self.headerTextView.textContainer.size.height;
        case 1:
            return self.contentTextView.textContainer.size.height;
        case 2:
            return self.answerTextView.textContainer.size.height;
        default:
            return 0;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
