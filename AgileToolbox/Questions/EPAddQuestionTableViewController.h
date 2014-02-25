//
//  EPAddQuestionTableViewController.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 20/02/14.
//
//

#import <UIKit/UIKit.h>
#import "EPQuestionsTableViewControllerStatePreservationAssistant.h"
#import "EPQuestionsDataSourceProtocol.h"

#import "EPPostmanDelegateProtocol.h"
#import "EPPostmanProtocol.h"

@interface EPAddQuestionTableViewController : UITableViewController<UITextViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)done:(id)sender;

@property (nonatomic,weak) EPQuestionsTableViewControllerStatePreservationAssistant* statePreservationAssistant;
@property (nonatomic,weak) id<EPQuestionsDataSourceProtocol> questionsDataSource;
@property (nonatomic,weak) id<EPPostmanProtocol> postman;

@end
