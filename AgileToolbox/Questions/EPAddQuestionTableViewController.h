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

@interface EPAddQuestionTableViewController : UITableViewController<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic,weak) EPQuestionsTableViewControllerStatePreservationAssistant* statePreservationAssistant;
@property (nonatomic,weak) id<EPQuestionsDataSourceProtocol> questionsDataSource;



@end
