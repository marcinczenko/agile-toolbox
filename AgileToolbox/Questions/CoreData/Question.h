//
//  Question.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 08/02/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * question_id;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSString * answer;

@end
