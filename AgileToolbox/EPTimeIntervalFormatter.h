//
//  EPTimeIntervalFormatter.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 12/02/14.
//
//

#import <Foundation/Foundation.h>

@interface EPTimeIntervalFormatter : NSObject

+ (NSString*)formatTimeIntervalStringFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

@end
