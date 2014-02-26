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
#import "EPAddQuestionConfirmationViewController.h"

#import "EPSnapshot.h"
#import "UIImage+ImageEffects.h"

@interface EPAddQuestionTableViewController ()

@property (nonatomic,assign) NSInteger length;

@property (nonatomic,assign) CGFloat previousHeight;

@property (nonatomic,assign) CGFloat keyboardHeight;

@property (nonatomic,readonly) CGFloat heightOfNavigationBarAndStatusBar;

@property (nonatomic,readonly) CGFloat headerRowHeight;
@property (nonatomic,readonly) CGFloat contentRowWidth;
@property (nonatomic,readonly) CGFloat contentRowInitialHeight;

@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) UITextField* textField;

@property (nonatomic,strong) UITableViewCell* textViewTableViewCell;
@property (nonatomic,strong) UITableViewCell* textFieldTableViewCell;

@property (nonatomic,strong) EPSnapshot* snapshot;

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

//- (CGPoint)checkContentOffset:(CGPoint)contentOffset
//{
//    CGFloat maxContentOffsetHeight = self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom;
//    NSLog(@"maxContentOffsetHeight:%f",maxContentOffsetHeight);
//    
//    return self.contentOffset.y > maxContentOffsetHeight ? CGPointMake(0, maxContentOffsetHeight) : self.contentOffset;
//}

- (void)setQuestionContentFont
{
    UIFontDescriptor* contentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleBody];
    UIFont* contentFont = [UIFont fontWithDescriptor:contentFontDescriptor size:0];
    
    self.textView.font = contentFont;
}

- (BOOL)viewIsVisible
{
    return (self.isViewLoaded && self.view.window);
}

- (void)preferredFontChanged: (NSNotification*)notification
{
    if ([self viewIsVisible]) {
        [self setQuestionContentFont];
        
        [self textViewDidChange:self.textView];
    }
}

- (void)printPositioningMetricsForTableView:(UITableView*)tableView withHeader:(NSString*)header
{
    NSLog(@"------------%@-----------------------------",header);
    NSLog(@"contentOffset:%@",NSStringFromCGPoint(tableView.contentOffset));
    NSLog(@"contentSize:%@",NSStringFromCGSize(tableView.contentSize));
    NSLog(@"contentInset:%@",NSStringFromUIEdgeInsets(tableView.contentInset));
    NSLog(@"bounds:%@",NSStringFromCGRect(tableView.bounds));
}


- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    NSDictionary* dict = [notification userInfo];
    CGRect keyboardFrame = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.keyboardHeight = keyboardFrame.size.height;
    
}

- (void)keyboardDidShowNotification:(NSNotification*)notification
{
}


- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    
}

- (void)willResignActiveNotification:(NSNotification*)paramNotification
{
    [self preserveUI];
}

- (void)willEnterForegroundNotification:(NSNotification*)notification
{
    
}

- (void)didBecomeActiveNotification:(NSNotification*)paramNotification
{
}

- (void) preserveUI
{
    self.statePreservationAssistant.addQuestionViewContentText = self.textView.text;
    self.statePreservationAssistant.addQuestionViewHeaderText = self.textField.text;
}

- (void)restoreUI
{
    self.textView.text = self.statePreservationAssistant.addQuestionViewContentText;
    self.textField.text = self.statePreservationAssistant.addQuestionViewHeaderText;
}

- (void)setupQuestionHeaderView
{
    self.textField = [UITextField new];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.delegate = self;
}

- (void)setupTableViewCells
{
    self.textFieldTableViewCell = [[EPQuestionHeaderTableViewCell alloc] initWithTextField:self.textField];
    self.textViewTableViewCell = [[EPQuestionContentTableViewCell alloc] initWithTextView:self.textView];
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
    [notificationCenter addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    
    
    [notificationCenter addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notificationCenter addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notificationCenter addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // will be corrected later, once keyboard notification arrives
    [self setEstimatedKeyboardHeight];
    
    [self setupNotifications];
    
    [self setupQuestionHeaderView];
    [self setupQuestionContentView];
    [self setupTableViewCells];

    [self restoreUI];
    [self adjustFrameForTextView:self.textView];
    self.previousHeight = self.textView.frame.size.height;
    
    [self updateSendButtonStatus];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self preserveUI];
    
    [self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"OFFSET:%@",NSStringFromCGPoint(self.tableView.contentOffset));
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
    [self updateSendButtonStatus];
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

- (void)textFieldDidChange:(UITextField*)textField
{
    [self updateSendButtonStatus];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.statePreservationAssistant.isContentViewFirstResponder = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

}

- (void)updateSendButtonStatus
{
    if (0==self.textView.text.length || 0==self.textField.text.length) {
        self.sendButton.enabled = NO;
    } else {
        self.sendButton.enabled = YES;
    }
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
    CGFloat cellHeight = (self.textView.frame.size.height > self.contentRowInitialHeight) ? self.textView.frame.size.height : self.contentRowInitialHeight;
    
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
        return self.textFieldTableViewCell;
    } else {
        return self.textViewTableViewCell;
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


// ---------------------- posting new question ---------------------------------

- (IBAction)done:(id)sender
{
    [self.view endEditing:YES];
    
    [self prepareSnapshot];
    
    [self showConfirmation];
}

- (void)prepareSnapshot
{
    
    UIImage* image = [EPSnapshot createSnapshotOfView:self.navigationController.view afterScreenUpdates:YES];
    
    self.snapshot = [[EPSnapshot alloc] initWithImage:image];

}

- (void)showConfirmation
{
    EPAddQuestionConfirmationViewController* viewController = [[EPAddQuestionConfirmationViewController alloc] init];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    viewController.snapshot = self.snapshot;
    viewController.postman = self.postman;
    
    [self presentViewController:viewController animated:NO completion:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.postman postQuestionWithHeader:self.textField.text content:self.textView.text];
    }];
}

@end
