//
//  QATTopicDetailsViewController.h
//  AgileToolbox
//
//  Created by AtrBea on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QATTopicDetailsViewController : UIViewController<UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (nonatomic, assign) IBOutlet UIWebView *webView;

@property (nonatomic, copy) NSString *topicDescription;

- (IBAction)exitFullScreen:(UITapGestureRecognizer *)sender;

@end
