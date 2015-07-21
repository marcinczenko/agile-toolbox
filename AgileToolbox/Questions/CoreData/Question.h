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
@property (nonatomic, retain) NSString * question_id;
@property (nonatomic, readwrite) BOOL updatedOrNew;
@property (nonatomic, retain) NSDate * sortUpdated;

@end
