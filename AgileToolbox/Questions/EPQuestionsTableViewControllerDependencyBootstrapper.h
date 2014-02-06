//
//  EPQuestionsTableViewControllerDependencyBootstrapper.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import <Foundation/Foundation.h>
#import "EPDependencyBox.h"

@class EPAppDelegate;

@interface EPQuestionsTableViewControllerDependencyBootstrapper : NSObject

- (instancetype)initWithAppDelegate:(EPAppDelegate*)appDelegate;
- (EPDependencyBox*)bootstrap;

@end
