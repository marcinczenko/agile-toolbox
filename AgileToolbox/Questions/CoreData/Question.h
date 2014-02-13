//
//  Question.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 12/02/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSNumber * question_id;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * newOrUpdated;

@end
