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
#import "EPQuestionUpdatedTextView.h"

#import "EPOverlayNotifierView.h"

#import "EPPersistentStoreHelper.h"

#import "EPAppDelegate.h"

static NSString* const kQuestionHeader = @"Header";
static NSString* const kQuestionContent = @"Content";
static NSString* const kQuestionAnswer = @"Answer";
static NSString* const kQuestionUpdated = @"Updated";

@interface EPQuestionDetailsTableViewController ()

@property (nonatomic,strong) EPQuestionHeaderTextView* headerTextView;
@property (nonatomic,strong) EPQuestionContentAndAnswerTextView* contentTextView;
@property (nonatomic,strong) EPQuestionContentAndAnswerTextView* answerTextView;
@property (nonatomic,strong) EPOverlayNotifierView* updatedDateView;
@property (nonatomic,strong) EPQuestionUpdatedTextView* updatedTextView;

@property (nonatomic,strong) NSMutableArray* textViews;

@property (nonatomic,copy) NSString* questionHeader;
@property (nonatomic,copy) NSString* questionContent;
@property (nonatomic,copy) NSString* questionAnswer;
@property (nonatomic,copy) NSDate* questionUpdated;

@end

@implementation EPQuestionDetailsTableViewController

+ (UIColor*)colorYellow
{
    return [UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1.0];
}

+ (UIColor*)colorGreen
{
    return [UIColor colorWithRed:60/255.0f green:152/255.0f blue:4/255.0f alpha:1.0f];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self decodeObjectWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [self encodeObjectWithCoder:aCoder];
}

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

- (void)setupTextViews
{
    self.textViews = [NSMutableArray arrayWithArray:@[@{@"color": [UIColor grayColor], @"view":[self setUpHeaderTextView]},
                                                      @{@"color": [self.class colorYellow], @"view":[self setUpContentTextView]},
                                                      @{@"color": [self.class colorGreen], @"view":[self setUpAnswerTextView]}]];
    

//    [self setUpUpdatedOverlayView];
}

- (void)configureView
{
    if (self.questionContent) {
        [self setupTextViews];
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

- (void)addUpdatedCellAnimated
{
    UITextView* textView = [self setupUpdatedTextView];
    
    [self.textViews insertObject:@{@"color": [self.class colorYellow], @"view":textView}
                         atIndex:0];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y+textView.contentSize.height);
    
    [UIView animateWithDuration:1.0 animations:^{
        self.tableView.contentOffset = contentOffset;
    }];
}

- (void)updateQuestionStatusInCoreData
{
    if (self.question.updatedOrNew) {
        self.question.updatedOrNew = NO;        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.questionUpdated) {
        [self addUpdatedCellAnimated];
//        [self.updatedDateView addToView:self.view for:3.0];
    }
    [self updateQuestionStatusInCoreData];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.textViews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UITextView*)self.textViews[indexPath.row][@"view"]).contentSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EPAttributedTextTableViewCell* cell = [EPAttributedTextTableViewCell cellDequeuedFromTableView:tableView
                                                                                      forIndexPath:indexPath
                                                                                     usingTextView:self.textViews[indexPath.row][@"view"]];
    
    cell.backgroundColor = self.textViews[indexPath.row][@"color"];
    
    return cell;
    
}

- (UITextView*)setUpHeaderTextView
{
    self.headerTextView = [[EPQuestionHeaderTextView alloc] initWithText:self.questionHeader];
    
    return self.headerTextView;
}


- (UITextView*)setUpContentTextView
{
    self.contentTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:self.questionContent];
    
    return self.contentTextView;
}

- (UITextView*)setUpAnswerTextView
{
    if (!self.question.answer || 0==self.question.answer.length) {
        self.answerTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:@"Awaiting answer..."];
    } else {
        self.answerTextView = [[EPQuestionContentAndAnswerTextView alloc] initWithText:self.questionAnswer];
    }
    
    return self.answerTextView;
}

- (UITextView*)setupUpdatedTextView
{
    self.updatedTextView = [[EPQuestionUpdatedTextView alloc] initWithText:[NSString stringWithFormat:@"Last updated on %@",[self stringFromDate:self.questionUpdated]]];
    self.updatedTextView.backgroundColor = [self.class colorYellow];
    self.updatedTextView.textAlignment = NSTextAlignmentCenter;
    
    return self.updatedTextView;
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
