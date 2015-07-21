//
//  EPTimeIntervalFormatterTests.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 12/02/14.
//
//

#import <XCTest/XCTest.h>

#import "EPTimeIntervalFormatter.h"

@interface EPTimeIntervalFormatterTests : XCTestCase

@property (nonatomic,strong) NSDate* dateNow;

@end

@implementation EPTimeIntervalFormatterTests

- (void)setUp
{
    [super setUp];
    
    self.dateNow = [NSDate date];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsLessThanOneMinute
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-30.0 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"just now", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsLessThan2Minutes
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-65.0 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"1 minute ago", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsLessThan10MinutesButMoreThan1Minute
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-60.0*5 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"5 minutes ago", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsAround1Hour
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-60.0*65.0 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"1 hour ago", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsAroundMultipleHours
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-60.0*60.0*5.0 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"5 hours ago", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsAround1day
{
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:-60.0*60.0*25.0 sinceDate:self.dateNow];
    
    XCTAssertEqualObjects(@"yesterday", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsMoreThanOneDayButLessThanAWeek
{
    double oneHour = 60.0*60.0;
    double oneday = oneHour*24.0;
    
    for (int i=2; i<7; i++) {
        double daysEgo = (-1.0)*oneday*(double)i;
        NSDate* dateInThePast = [NSDate dateWithTimeInterval:daysEgo sinceDate:self.dateNow];
        NSString* formatedDate = [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow];
        BOOL status = [@[@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"]
                       containsObject:formatedDate];
        
        
        XCTAssertTrue(status, @"%d:%@",i,formatedDate);
    }
}

- (NSDate*)generateDateFromString:(NSString*)dateString
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd MM yyyy HH:mm a"];
    return [df dateFromString:dateString];
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsOneWeekAgo
{
    NSString* referenceDate = @"11 01 2014 12:00 PM";
    
    double oneHour = 60.0*60.0;
    double oneday = oneHour*24.0;
    double daysEgo = (-1.0)*oneday*7.0;
    
    NSDate* dateInThePast = [NSDate dateWithTimeInterval:daysEgo sinceDate:[self generateDateFromString:referenceDate]];
    
    XCTAssertEqualObjects(@"January 4, 2014", [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:dateInThePast toDate:self.dateNow]);
}

- (void)testFormatingTheDisplayedDateWhenDifferenceBetweenTheCurrentDateAndInputIsMoreThanAYear
{
    NSDate* someImportantDayInThePast = [self generateDateFromString:@"25 10 1978 12:00 PM"];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];

    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    XCTAssertEqualObjects([dateFormatter stringFromDate:someImportantDayInThePast], [EPTimeIntervalFormatter formatTimeIntervalStringFromDate:someImportantDayInThePast
                                                                                                                                       toDate:self.dateNow]);
}


@end
