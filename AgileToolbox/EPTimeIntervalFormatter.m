//
//  EPTimeIntervalFormatter.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 12/02/14.
//
//

#import "EPTimeIntervalFormatter.h"

static NSDateFormatter* dateFormatter = nil;

@implementation EPTimeIntervalFormatter

+ (BOOL)justNow:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year &&
        0 == dateComponents.month &&
        0 == dateComponents.day &&
        0 == dateComponents.hour &&
        0 == dateComponents.minute) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)minutesAgo:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year &&
        0 == dateComponents.month &&
        0 == dateComponents.day &&
        0 == dateComponents.hour) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)hoursAgo:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year &&
        0 == dateComponents.month &&
        0 == dateComponents.day) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)yesterday:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year &&
        0 == dateComponents.month &&
        1 == dateComponents.day) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)lessThanAWeekAgo:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year &&
        0 == dateComponents.month &&
        7 > dateComponents.day) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)lessThanAYearAgo:(NSDateComponents*)dateComponents
{
    if (0 == dateComponents.year) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*)weekDayFromDate:(NSDate*)date
{
    if (nil == dateFormatter) {
        dateFormatter = [NSDateFormatter new];
    }
    
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)dayAndMonthOnlyFromDate:(NSDate*)date
{
    if (nil == dateFormatter) {
        dateFormatter = [NSDateFormatter new];
    }
    
    [dateFormatter setDateFormat:@"d MMMM"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)longFormatFromDate:(NSDate*)date
{
    if (nil == dateFormatter) {
        dateFormatter = [NSDateFormatter new];
    }
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}


+ (NSString*)formatTimeIntervalStringFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    NSCalendarUnit conversionUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    NSCalendar* currentUserCalendar = [NSCalendar currentCalendar];
    
    NSDateComponents* conversionComponents = [currentUserCalendar components:conversionUnits fromDate:fromDate toDate:toDate options:0];
    
    if ([self justNow:conversionComponents]) {
        return @"just now";
    } else if ([self minutesAgo:conversionComponents]) {
        if (1 == conversionComponents.minute) {
            return [NSString stringWithFormat:@"%ld minute ago",(long)[conversionComponents minute]];
        } else {
            return [NSString stringWithFormat:@"%ld minutes ago",(long)[conversionComponents minute]];
        }
    } else if ([self hoursAgo:conversionComponents]) {
        if (1 == conversionComponents.hour) {
            return [NSString stringWithFormat:@"%ld hour ago",(long)[conversionComponents hour]];
        } else {
            return [NSString stringWithFormat:@"%ld hours ago",(long)[conversionComponents hour]];
        }
    } else if ([self yesterday:conversionComponents]) {
        return @"yesterday";
    } else if ([self lessThanAWeekAgo:conversionComponents]) {
        return [self weekDayFromDate:fromDate];
    } else if ([self lessThanAYearAgo:conversionComponents]) {
        return [self dayAndMonthOnlyFromDate:fromDate];
    } else {
        return [self longFormatFromDate:fromDate];
    }
    
    return [NSString stringWithFormat:@"%ld",(long)[conversionComponents second]];
}

@end
