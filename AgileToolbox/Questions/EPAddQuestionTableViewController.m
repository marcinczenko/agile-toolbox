//
//  EPAddQuestionTableViewController.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import "EPAddQuestionTableViewController.h"
#import "EPQuestionHeaderTableViewCell.h"
#import "EPQuestionContentTableViewCell.h"
#import "EPQuestionTextView.h"

@interface EPAddQuestionTableViewController ()

@property (nonatomic,assign) NSInteger length;

@property (nonatomic,assign) CGFloat previousHeight;

@property (nonatomic,assign) CGFloat keyboardHeight;

@property (nonatomic,readonly) CGFloat heightOfNavigationBarAndStatusBar;

@property (nonatomic,readonly) CGFloat headerRowHeight;
@property (nonatomic,readonly) CGFloat contentRowWidth;
@property (nonatomic,readonly) CGFloat contentRowInitialHeight;

@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) UITextField* headerView;


@end

@implementation EPAddQuestionTableViewController

- (void)setEstimatedKeyboardHeight
{
    self.keyboardHeight = 216.0;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setQuestionContentFont
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleBody];
    UIFont* contentFont = [UIFont fontWithDescriptor:contentFontDescriptor size:0];
    
    self.textView.font = contentFont;
}

- (void)preferredFontChanged: (NSNotification*)notification
{
    [self setQuestionContentFont];
    
    [self textViewDidChange:self.textView];
}

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    NSDictionary* dict = [notification userInfo];
    CGRect keyboardFrame = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.keyboardHeight = keyboardFrame.size.height;
}

- (void)willResignActiveNotification:(NSNotification*)paramNotification
{
    [self preserveUI];
}

- (void)didBecomeActiveNotification:(NSNotification*)paramNotification
{
}

- (void) preserveUI
{
    self.statePreservationAssistant.selectedRange = self.textView.selectedRange;
    self.statePreservationAssistant.isContentViewFirstResponder = self.textView.isFirstResponder;
    self.statePreservationAssistant.addQuestionViewContentText = self.textView.text;
    self.statePreservationAssistant.addQuestionViewHeaderText = self.headerView.text;
    self.statePreservationAssistant.addQuestionContentCellHeight = self.previousHeight;
    self.statePreservationAssistant.addQuestionTableViewContentOffset = self.tableView.contentOffset;
}

- (void)restoreUI
{
    self.textView.text = self.statePreservationAssistant.addQuestionViewContentText;
    self.headerView.text = self.statePreservationAssistant.addQuestionViewHeaderText;
    self.textView.selectedRange = self.statePreservationAssistant.selectedRange;
    self.previousHeight = self.statePreservationAssistant.addQuestionContentCellHeight;
    if (!CGPointEqualToPoint(CGPointZero, self.statePreservationAssistant.addQuestionTableViewContentOffset)) {
        self.tableView.contentOffset = self.statePreservationAssistant.addQuestionTableViewContentOffset;
    }
    if (self.statePreservationAssistant.isContentViewFirstResponder) {
        [self.textView  becomeFirstResponder];
    } else {
        [self.headerView becomeFirstResponder];
    }
}

- (void)setupQuestionHeaderView
{
    self.headerView = [UITextField new];
}

- (void)setupQuestionContentView
{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, self.contentRowWidth, self.contentRowInitialHeight)];
    self.textView.scrollEnabled = NO;
    self.textView.delegate = self;
    
    [self setQuestionContentFont];
}

- (void)setupNotifications
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(preferredFontChanged:) name:UIContentSizeCategoryDidChangeNotification object:[UIApplication sharedApplication]];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notificationCenter addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // will be corrected later, once keyboard notification arrives
    [self setEstimatedKeyboardHeight];
    
    [self setupNotifications];
    
    [self setupQuestionHeaderView];
    [self setupQuestionContentView];
    
    [self restoreUI];
    [self adjustFrameForTextView:self.textView];
    //[self textViewDidChange:self.textView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!CGPointEqualToPoint(CGPointZero, self.statePreservationAssistant.addQuestionTableViewContentOffset)) {
        self.tableView.contentOffset = self.statePreservationAssistant.addQuestionTableViewContentOffset;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self preserveUI];
    
    [super viewWillDisappear:animated];
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
    return 2;
}

- (void)adjustFrameForTextView:(UITextView*)textView
{
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    if (300 != frame.size.width) {
        frame.size.width = 300;
    }
    if (244 > frame.size.height) {
        frame.size.height = 244.0;
    }
    textView.frame = frame;
}

- (void)triggerTableViewRowHeightRecalculation
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustFrameForTextView:textView];
    
    [self updateTableViewScrollPosition];
    
    if (self.previousHeight != textView.frame.size.height) {
        self.previousHeight = textView.frame.size.height;
        
        [self triggerTableViewRowHeightRecalculation];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.statePreservationAssistant.isContentViewFirstResponder = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.statePreservationAssistant.isContentViewFirstResponder = NO;
}
 
- (CGFloat)headerRowHeight
{
    return 44.0;
}

- (CGFloat)contentRowWidth
{
    return 300.0;
}

- (CGFloat)heightOfNavigationBarAndStatusBar
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)contentRowInitialHeight
{
    return self.tableView.frame.size.height - self.keyboardHeight - self.heightOfNavigationBarAndStatusBar - self.headerRowHeight;
}

- (CGFloat)scrollTresholdForLineHeight:(CGFloat)lineHeight
{
    CGFloat screenSize = self.tableView.frame.size.height;
    CGFloat extraSpace = lineHeight+10;
    
    return screenSize - self.keyboardHeight - extraSpace;
}

- (void)updateTableViewScrollPosition
{
    CGRect currentLineRect = [self.textView caretRectForPosition:
                              self.textView.selectedTextRange.start];
    
    CGFloat positionOnScreen = [self.navigationController.view convertRect:currentLineRect fromView:self.textView].origin.y;
    CGFloat scrollTreshold = [self scrollTresholdForLineHeight:currentLineRect.size.height];
    
    CGFloat delta = positionOnScreen - scrollTreshold;
    
    if (delta > 0) {
        CGPoint offset = self.tableView.contentOffset;
        offset.y += delta;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.tableView.contentOffset = offset;
        }];
    }
}

- (CGFloat)contentRowHeight
{
    CGFloat cellHeight = (self.previousHeight > self.contentRowInitialHeight) ? self.previousHeight : self.contentRowInitialHeight;
    
    return ceil(cellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (0 == indexPath.row) {
        return [self headerRowHeight];
    } else {
        return [self contentRowHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        EPQuestionHeaderTableViewCell* cell = [EPQuestionHeaderTableViewCell cellDequeuedFromTableView:tableView
                                                                                          forIndexPath:indexPath
                                                                                         withTextField:self.headerView];
        return cell;
    } else {
        static NSString *cellIdentifier = @"QuestionContentTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[EPQuestionContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier textView:self.textView];
        }
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0==indexPath.row) {
        return NO;
    }
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
