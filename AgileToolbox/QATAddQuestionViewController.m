//
//  QATAddQuestionViewController.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 7/13/12.
//  Copyright (c) 2012 Everyday Productive. All rights reserved.
//

#import "QATAddQuestionViewController.h"

@interface QATAddQuestionViewController ()

@end

@implementation QATAddQuestionViewController
@synthesize delegate = _delegate;
@synthesize addedQuestionText = _addedQuestionText;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.addedQuestionText.accessibilityLabel = @"NewQuestionTextField";
}

- (void)viewDidUnload
{
    [self setAddedQuestionText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    
    [self.delegate questionAdded:self.addedQuestionText.text];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
