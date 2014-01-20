//
//  Question.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 15/01/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * question_id;
@property (nonatomic, retain) NSDate * timestamp;

@end
