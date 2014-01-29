//
//  EPPersistentStore.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 28/01/14.
//
//

#import <Foundation/Foundation.h>

@interface EPPersistentStoreHelper : NSObject

+ (void)storeDictionary:(NSDictionary*)dictionary toFile:(NSString*)fileName;
+ (NSDictionary*)readDictionaryFromFile:(NSString*)fileName;

@end
