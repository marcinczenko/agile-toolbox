//
//  QATViewController.m
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QATViewController.h"

@interface QATViewController ()

@property (nonatomic, strong) UIImage *backgroundImagePortraitOrientation;
@property (nonatomic, strong) UIImage *backgroundImageLandscapeOrientation;

//-(IBAction)Add:(id)sender;

@end

@implementation QATViewController

@synthesize backgroundImagePortraitOrientation = _backgroundImagePortraitOrientation;
@synthesize backgroundImageLandscapeOrientation = _backgroundImageLandscapeOrientation;

- (UIImage*)backgroundImagePortraitOrientation
{
    if (!_backgroundImagePortraitOrientation) {
        _backgroundImagePortraitOrientation = [UIImage imageNamed:@"QATBackground.png"];
    }
    return _backgroundImagePortraitOrientation;
}

- (UIImage*)backgroundImageLandscapeOrientation
{
    if (!_backgroundImageLandscapeOrientation) {
        _backgroundImageLandscapeOrientation = [UIImage imageNamed:@"QATBackgroundR.png"];
    }
    return _backgroundImageLandscapeOrientation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//-(IBAction)Add:(id)sender
//{
//    NSLog(@"ADD");
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
//    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        UIColor *background = [[UIColor alloc] initWithPatternImage:self.backgroundImageLandscapeOrientation];
//        self.view.backgroundColor = background;
//    } else {
//        UIColor *background = [[UIColor alloc] initWithPatternImage:self.backgroundImagePortraitOrientation];
//        self.view.backgroundColor = background;
//    }
    
    UIImageView *quantumLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QuantumNavigationBarLogo"]];
    
//    UIBarButtonItem *quantumLogoBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"QuantumNavigationBarLogo"] style:UIBarButtonItemStyleBordered target:self action:@selector(Add:)];
    
//    UIBarButtonItem *quantumLogoBarItem = [[UIBarButtonItem alloc] initWithCustomView:quantumLogo];
    self.navigationItem.titleView = quantumLogo;
//    self.navigationItem.rightBarButtonItem = quantumLogoBarItem;
    
//    UIColor *background = [[UIColor alloc] initWithPatternImage:self.backgroundImagePortraitOrientation];
//    self.view.backgroundColor = background;

    
    self.title = @"Quantum Agile Toolbox";
    
//    CGRect frame = [self.view viewWithTag:1].frame;
//    
//    CGSize size = self.view.bounds.size;
//    
//    frame.origin.x = (size.width - frame.size.width*2)/3;
//    frame.origin.y = (size.height - frame.size.height)/2;
//    
//    [self.view viewWithTag:1].frame = frame ;
//    
//    frame.origin.x = frame.origin.x*2 + frame.size.width;
//    
//    [self.view viewWithTag:2].frame = frame ;

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    NSLog(@"bounds.origin.x: %f", self.view.bounds.origin.x);
//    NSLog(@"bounds.origin.y: %f", self.view.bounds.origin.y);
//    NSLog(@"bounds.size.width: %f", self.view.bounds.size.width);
//    NSLog(@"bounds.size.height: %f", self.view.bounds.size.height);
    
//    CGRect frame = [self.view viewWithTag:1].frame;
//    
//    CGSize size = self.view.bounds.size;
//    
//    frame.origin.x = (size.width - frame.size.width*2)/3;
//    frame.origin.y = (size.height - frame.size.height)/2;
//    
//    NSLog(@"frame.origin.x: %f", frame.origin.x);
//    NSLog(@"frame.origin.y: %f", frame.origin.y);
//    
//    [self.view viewWithTag:1].frame = frame ;
//    
//    frame.origin.x = frame.origin.x*2 + frame.size.width;
//    
//    [self.view viewWithTag:2].frame = frame ;
//
//    
//    NSLog(@"frame.origin.x: %f", frame.origin.x);
//    NSLog(@"frame.origin.y: %f", frame.origin.y);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        UIColor *background = [[UIColor alloc] initWithPatternImage:self.backgroundImageLandscapeOrientation];
//        self.view.backgroundColor = background;
//    } else {
//        UIColor *background = [[UIColor alloc] initWithPatternImage:self.backgroundImagePortraitOrientation];
//        self.view.backgroundColor = background;
//    }
    
    
    
    
//    CGRect frame = [self.view viewWithTag:1].frame;
//    
//    CGSize size = self.view.bounds.size;
//    
//    frame.origin.x = (size.width - frame.size.width*2)/3;
//    frame.origin.y = (size.height - frame.size.height)/2;
//    
//    [self.view viewWithTag:1].frame = frame ;
//    
//    frame.origin.x = frame.origin.x*2 + frame.size.width;
//    
//    [self.view viewWithTag:2].frame = frame ;

    
//    frame.origin.x = frame.origin.x*2 + frame.size.width;
//    
//    [self.view viewWithTag:2].frame = frame ;
    
//    NSLog(@"frame.origin.x: %f", [self.view viewWithTag:1].frame.origin.x);
//    NSLog(@"frame.origin.y: %f", [self.view viewWithTag:1].frame.origin.y);
//    NSLog(@"frame.size.width: %f", [self.view viewWithTag:1].frame.size.width);
//    NSLog(@"frame.size.height: %f", [self.view viewWithTag:1].frame.size.height);
//    
//    NSLog(@"frame.origin.x: %f", [self.view viewWithTag:2].frame.origin.x);
//    NSLog(@"frame.origin.y: %f", [self.view viewWithTag:2].frame.origin.y);
//    NSLog(@"frame.size.width: %f", [self.view viewWithTag:2].frame.size.width);
//    NSLog(@"frame.size.height: %f", [self.view viewWithTag:2].frame.size.height);
    
//    NSEnumerator *enumerator = [self.view.subviews objectEnumerator];
//    UIView* subView;
//    
//    while (subView = [enumerator nextObject]) {
//        
//        NSLog(@"frame.origin.x: %f", subView.frame.origin.x);
//        NSLog(@"frame.origin.y: %f", subView.frame.origin.y);
//        NSLog(@"frame.size.width: %f", subView.frame.size.width);
//        NSLog(@"frame.size.height: %f", subView.frame.size.height);
//    }
    
    //  label.frame.origin.x
//    for (; <#condition#>; <#increment#>) {
//        <#statements#>
//    }
//    NSLog(@"frame.origin.x: %f", [[self.view.subviews objectAtIndex:0] bounds].origin.x);
//    NSLog(@"frame.origin.y: %f", label.frame.origin.y);
//    NSLog(@"frame.size.width: %f", label.frame.size.width);
//    NSLog(@"frame.size.height: %f", label.frame.size.height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.title = @"Toolbox";
//    if ([@"topicsList" isEqualToString:segue.identifier]) {
//        self.title = @"Toolbox";
//    }
}


@end
