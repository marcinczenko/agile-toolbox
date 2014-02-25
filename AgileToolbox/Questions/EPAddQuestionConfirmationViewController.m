//
//  EPAddQuestionConfirmationViewController.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 22/02/14.
//
//

#import "EPAddQuestionConfirmationViewController.h"

#import "EPQuestionsTableViewExpert.h"

static NSString* const EPAddQuestionConfirmationTextSuccess = @"Your question has been successfully submitted and once accepted will appear on the list of questions.\n Please note that we may refine your question to make it more appropriate for the reader.";
static NSString* const EPAddQuestionConfirmationTextFailure = @"There was a problem with submitting your question. Please check your network connection and try again later. Please let us know if the problem persists.";

typedef enum {
    EPAddQuestionConfirmationStyleSuccess,
    EPAddQuestionConfirmationStyleFailure
} EPAddQuestionConfirmationStyle;

@interface EPAddQuestionConfirmationViewController ()

@end

@implementation EPAddQuestionConfirmationViewController

+ (UIColor*)colorGreen
{
    return [UIColor colorWithRed:60/255.0f green:152/255.0f blue:4/255.0f alpha:1.0f];
}

+ (UIColor*)colorRed
{
    return [UIColor colorWithRed:217/255.0f green:11/255.0f blue:11/255.0f alpha:1.0f];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.postman setDelegate:self];
    
    [self.snapshot displayInView:self.view withTag:1402220315 originComputationBlock:^CGPoint{
        return CGPointMake(0, 0);
    }];
    
    [self displayActivityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayActivityIndicator
{
    UIView* spinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
    spinView.layer.cornerRadius = 10.0;
    spinView.backgroundColor = [EPQuestionsTableViewExpert colorQuantum];
    
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicatorView.frame = CGRectMake(0, 0, 30, 30);
    
    [spinView addSubview:activityIndicatorView];
    
    
    activityIndicatorView.center = spinView.center;
    spinView.center = self.view.center;
    spinView.tag = 20140221;
    
    [self.view addSubview:spinView];
    
    [activityIndicatorView startAnimating];
}

- (void)dismissNotification:(id)sender
{
    UIView* view = [self.view viewWithTag:1402220244];
    
    [UIView animateWithDuration:1.0 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
        [view removeFromSuperview];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)addButtonToView:(UIView*)view
        withBorderColor:(UIColor*)borderColor
        backgroundColor:(UIColor*)backgroundColor
              tintColor:(UIColor*)tintColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(dismissNotification:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Got it!" forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    if (borderColor) {
        button.layer.borderColor = [borderColor CGColor];
        button.layer.borderWidth = 1.0;
    }
    button.tintColor = tintColor;
    button.backgroundColor = backgroundColor;
    button.frame = CGRectMake(0, 0, 100, 44);
    CGPoint center = view.center;
    center.y = view.frame.size.height - 15 - 22;
    button.center = center;
    [view addSubview:button];
}

- (void)addConfirmationLabelToView:(UIView*)view
                          withText:(NSString*)text
                         textColor:(UIColor*)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, view.frame.size.width-30, view.frame.size.height - 15 - 44 - 30)];
    
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:13.0];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    CGPoint center = view.center;
    center.y = label.center.y;
    label.center = center;
    [view addSubview:label];
}

- (void)showConfirmationWithStyle:(EPAddQuestionConfirmationStyle)style
{
    switch (style) {
        case EPAddQuestionConfirmationStyleSuccess:
            [self showConfirmationWithText:EPAddQuestionConfirmationTextSuccess
                                 textColor:[UIColor blackColor]
                           backgroundColor:[UIColor whiteColor]
                               borderColor:[EPQuestionsTableViewExpert colorQuantum]
                     buttonBackgroundColor:[EPQuestionsTableViewExpert colorQuantum]
                         buttonBorderColor:nil
                           buttonTintColor:[UIColor whiteColor]];
            break;
        case EPAddQuestionConfirmationStyleFailure:
            [self showConfirmationWithText:EPAddQuestionConfirmationTextFailure
                                 textColor:[UIColor whiteColor]
                           backgroundColor:[EPQuestionsTableViewExpert colorQuantum]
                               borderColor:[EPQuestionsTableViewExpert colorQuantum]
                     buttonBackgroundColor:[UIColor whiteColor]
                         buttonBorderColor:nil
                           buttonTintColor:[EPQuestionsTableViewExpert colorQuantum]];
        default:
            break;
    }
}

- (void)showConfirmationWithText:(NSString*)text
                       textColor:(UIColor*)textColor
                 backgroundColor:(UIColor*)backgroundColor
                     borderColor:(UIColor*)borderColor
           buttonBackgroundColor:(UIColor*)buttonBackgroundColor
               buttonBorderColor:(UIColor*)buttonBorderColor
                 buttonTintColor:(UIColor*)buttonTintColor
{
    
    UIView* confirmationView = [[UIView alloc] initWithFrame:self.view.bounds];
    confirmationView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.55];
    confirmationView.tag = 1402220244;
    
    UIView* alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 200)];
    
    if (borderColor) {
        alertView.layer.borderColor = [borderColor CGColor];
        alertView.layer.borderWidth = 2.0;
    }
    alertView.layer.cornerRadius = 30.0;
    alertView.backgroundColor = backgroundColor;
    
    [self addButtonToView:alertView
          withBorderColor:buttonBorderColor
          backgroundColor:buttonBackgroundColor
                tintColor:buttonTintColor];
    [self addConfirmationLabelToView:alertView
                            withText:text
                           textColor:textColor];
    
    alertView.center = confirmationView.center;
    
    [confirmationView addSubview:alertView];
    
    UIView* activityIndicatorView = [self.view viewWithTag:20140221];
    
    [UIView transitionFromView:activityIndicatorView toView:confirmationView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
}

#pragma mark - EPPostmanDelegateProtocol
- (void)postDelivered
{
    [self showConfirmationWithStyle:EPAddQuestionConfirmationStyleSuccess];
}

- (void)postDeliveryFailed
{
    [self showConfirmationWithStyle:EPAddQuestionConfirmationStyleFailure];
}


@end
